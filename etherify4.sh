#!/bin/bash

# Etherify 4 - silly hack to send data wirelessly by changing the speed
#              of an ethernet interface. THis is an implementation for
#              devices which change speed slowly
#
# (c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>
# https://lipkowski.com/etherify
#
# Tested on two Dell Laptops: Latitude 6220 running debian bullseye 
# (transmitter) and Latitude D610 running debian stretch (passively sitting
# on the other side of the ethernet link)
# This works by switching between 10Mbps and 100Mbps, which results
# in a change of the electromagnetic radiation that leaks from the devices.
# Switching to 100Mbps produces a signal at 125MHz and it's harmonics, 
# which is used to transmit slow morse code.
#
# This enables one to leak data out via morse code.
#
# To receive use software for slow telegraphy (search for QRSS CW),
# such as an sdr receiver and DL4YHF Spectrum Lab
#
# During tests the signal could be received at a distance of 7m.
# Longer distances might work also, but haven't been tested.
#
# Notice:
# - conduct the tests in an electromagnetically quiet area
# - make sure that there is an ethernet link
# - run this as root
# - listen at integer multiples od 125MHz, often they are stronger

#
# This script is licensed under GPL v3
#
# I disclaim any liability for things that this software does or doesn't do.
# Everything is the responsibility of the user.
#




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


txon() {
	ethtool -s $NETDEVICE autoneg off duplex full speed 100
}

txoff() {
	ethtool -s $NETDEVICE  autoneg off duplex full speed 10
}

wait_linkdetected() {
	while : ; do 
		ethtool $NETDEVICE | grep 'Link detected: yes' >/dev/null && break
		sleep 0.01
	done
}

calibrate() {
	echo "calibrating link renegotiation time"
	txoff; txon
	TXBEGIN=$EPOCHREALTIME
	wait_linkdetected
	TXEND=$EPOCHREALTIME
	LINKDELAY=`echo -e "scale=5\n${TXEND}-${TXBEGIN}"| bc -l`
}


etherify4_send() {
	B="$1"
	while [ "$B" ]; do
		C="${B:0:1}"
		B="${B:1}"
		echo -n "$C"
		txon; sleep 0.1; txoff #hack

		case "$C" in
			"-") txon; wait_linkdetected ; sleep $SLEEPDASH ;;
			".") txon; wait_linkdetected; sleep $SLEEPDOT ;;
			" ") txoff; sleep $SLEEPDASH  ;;
		esac
		txoff
	done
	echo
}

find_ethernet_device() {
	for i in /sys/class/net/*
	do
		j=`basename $i`
		ethtool $j | grep Duplex >/dev/null && echo $j && return
	done
	echo "No suitable ethernet device found"
	exit 1
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
Etherify 4 , sending wireless by manipulating interface speed. 
Please tune around 125MHz QRSS CW, or it's harmonics 250MHz, 375MHz, 500MHz etc
(c) 2020 Jacek Lipkowski SQ5BPF 

EOF


find_prerequisites bc ethtool

[ ! "$NETDEVICE" ] && NETDEVICE=`find_ethernet_device` 

echo "Using network device $NETDEVICE"

calibrate

A=`echo -e "scale=5; $LINKDELAY > 0.1" | bc -l`
if [ "$A" = 0 ]; then
	echo "The link-change delay is too small, use etherify1.sh instead"
	exit 1
fi

TEXT="etherify4demo="
[ "$1" -a -f "$1" ] &&  TEXT=`tr '\n' ' ' < $1 | sed -re 's/  */ /g'`
CWTEXT=`text2morse "$TEXT"`

cat <<EOF
Sending: "${TEXT}"
$CWTEXT

EOF


SLEEPDOT=$LINKDELAY
SLEEPDASH=`echo -e "scale=5\n${LINKDELAY}*3"| bc -l`
SLEEPSPACE=`echo -e "scale=5\n${LINKDELAY}*2"| bc -l`


echo "delay: $LINKDELAY seconds"
echo "dot: $SLEEPDOT seconds dash: $SLEEPDASH seconds"



if ethtool $NETDEVICE | grep 'Link detected: yes' > /dev/null; then

	while : ; do
		etherify4_send "$CWTEXT"
		sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE
	done

else
	echo "Aborting, there is no ethernet link on interface $NETDEVICE"

fi
