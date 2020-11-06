#!/bin/bash

# Etherify 2 - silly hack to send data wirelessly by generating load on 
#              the ethernet interface.
#
# (c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>
# https://lipkowski.com/etherify
#
# Tested on 2 raspberry pi 4 connected together via 2m ethernet cable
# This probably works by loading the supply voltage when the packets
# are generated. A change of voltage probably  changes the frequency
# of some clock slightly, thus generating FSK (F1A to be exact).
#
# This enables one to leak data out via morse code.
# Please tune the receiver to around 125MHz in CW mode with a 
# very narrow filter. 
#
# During tests the signal could be received at a distance of 30m.
#
# Notice:
# - conduct the tests in an electromagnetically quiet area
# - software decodera are very bad at decoding morse code in the presence 
#   of interference, and with imperfect timing. If you want to asess if the
#   signal is decodable, then get someone who can receive by ear
#   (such as an experienced amateur radio operator). 
#   Humans are way better at this.
# - make sure that you can ping the other raspberry pi before running this demo
# - run this as root (could be made to run non-root with udp)

#
# This script is licensed under GPL v3
#
# I disclaim any liability for things that this software does or doesn't do.
# Everything is the responsibility of the user.
#

#etherify2 settings:
# a pingable address (of the second raspberry pi 4)
IP=192.168.1.1

#this gives around 17wpm on a raspberry pi 4
#modify these if you need faster/slower cw
DOTLEN=350
DASHLEN=$((${DOTLEN}*3))
SLEEPDOT=0.05
SLEEPDASH=0.15
SLEEPSPACE=0.10


#simple cw encoder --sq5bpf
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



etherify2_send() {
	B="$1"
	while [ "$B" ]; do
		C="${B:0:1}"
		B="${B:1}"
		echo -n "$C"

		case "$C" in
"-") ping -f -s 1440 -c $DASHLEN $IP >/dev/null 2>&1 ;;
".") ping -f -s 1440 -c $DOTLEN $IP >/dev/null 2>&1 ;;
" ") sleep $SLEEPSPACE ;;
		esac
		sleep $SLEEPDOT
	done
	echo
}



TEXT=" etherify 2 demo="
[ "$1" -a -f "$1" ] &&  TEXT=`tr '\n' ' ' < $1 | sed -re 's/  */ /g'`
CWTEXT=`text2morse "$TEXT"`

cat <<EOF
Etherify 2 , sending wireless by generating traffic to ${IP}
Please tune around 125MHz CW with a narrow filter.
(c) 2020 Jacek Lipkowski SQ5BPF 

Sending: "${TEXT}"
$CWTEXT

EOF

if ping -c 2 -W 1  -i 1 $IP >/dev/null 2>&1 ; then

while : ; do
	etherify2_send "$CWTEXT"
	sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE ; sleep $SLEEPSPACE
done

else
echo "Aborting, I can't ping $IP"

fi
