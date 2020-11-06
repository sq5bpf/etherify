#!/bin/bash

# Etherify 1 - silly hack to send data wirelessly by changind the speed
#              of an ethernet interface.
#
# (c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>
# https://lipkowski.com/etherify
#
# Tested on 2 raspberry pi 4 connected together via 2m ethernet cable
# This works by switching between 10Mbps and 100Mbps, which results
# in a change of the electromagnetic radiation that leaks from the devices.
# Switching to 100Mbps produces a signal at 125MHz, which is used to
# transmit morse code.
#
# This enables one to leak data out via morse code.
# Please tune the receiver to around 125MHz in CW mode with a
# very narrow filter.
#
# During tests the signal could be received at a distance of 100m.
#
# Notice:
# - conduct the tests in an electromagnetically quiet area
# - software decodera are very bad at decoding morse code in the presence
#   of interference, and with imperfect timing. If you want to asess if the
#   signal is decodable, then get someone who can receive by ear
#   (such as an experienced amateur radio operator).
#   Humans are way better at this.
# - make sure that there is an ethernet link to the other raspberry pi
# - run this as root

#
# This script is licensed under GPL v3
#
# I disclaim any liability for things that this software does or doesn't do.
# Everything is the responsibility of the user.
#


#etherify1 settings:
NETDEVICE=eth0

#this gives around 18-20wpm
#modify these if you need faster/slower cw
SLEEPDOT=0.05
SLEEPDASH=0.15
SLEEPSPACE=0.10



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

etherify1_send() {
	txoff 
	B="$1"
	while [ "$B" ]; do
		C="${B:0:1}"
		B="${B:1}"
		echo -n "$C"
		txon; txoff #hack

		case "$C" in
			"-") txon; sleep $SLEEPDASH; txoff ;;
			".") txon; sleep $SLEEPDOT; txoff ;;
			" ") txoff; sleep $SLEEPSPACE ; txoff ;;
		esac
		sleep $SLEEPDOT
	done
	echo
}



TEXT=" etherify 1 demo="
[ "$1" -a -f "$1" ] &&  TEXT=`tr '\n' ' ' < $1 | sed -re 's/  */ /g'`
CWTEXT=`text2morse "$TEXT"`

cat <<EOF
Etherify 1 , sending wireless by manipulating interface speed. 
Please tune around 125MHz CW
(c) 2020 Jacek Lipkowski SQ5BPF 

Sending: "${TEXT}"
$CWTEXT

EOF

if ethtool $NETDEVICE | grep 'Link detected: yes'; then

while : ; do
	etherify1_send "$CWTEXT"
	sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE
done

else
echo "Aborting, there is no ethernet link on interface $NETDEVICE"

fi
