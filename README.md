Etherify - bringing the ether back to ethernet

(c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>

Main page here: https://lipkowski.com/etherify
Demo:  https://youtu.be/ueC4SLPrtNg


These are attempts to transmit via leakage from ethernet.


################################################################

etherify1.sh  - sends data wirelessly by changing the speed of an 
ethernet interface.

Usage:

./etherify1.sh <file>

If <file> is  given, then the contents are sent, else "etherify 1 demo" is sent.

This works by switching between 10Mbps and 100Mbps, which results
in a change of the electromagnetic radiation that leaks from the devices.
Switching to 100Mbps produces a signal at 125MHz, which is used to
transmit morse code.


Tested on 2 raspberry pi 4 running Raspbian 10 
connected together via 2m ethernet cable

On the other raspberry pi:

killall dhcpcd #disable any other software messing with the eth0 interface, such as NetworkManager

ifconfig eth0 up

ethtool eth0  #verify link is up

./etherify1.sh /tmp/secret.txt  #to leak out the contents of /tmp/secret.txt
./etherify1.sh                  # or just to send the standard text


Watch the demo:
[![Watch the etherify 1 demo](https://img.youtube.com/vi/ueC4SLPrtNg/hqdefault.jpg)](https://youtu.be/ueC4SLPrtNg)


################################################################

etherify2.sh  -  silly hack to send data wirelessly by generating load on
 the ethernet interface.

Usage:

./etherify2.sh <file>

If <file> is  given, then the contents are sent, else "etherify 2 demo" is sent.

Tested on 2 raspberry pi 4 running Raspbian 10 
connected together via 2m ethernet cable
This probably works by loading the supply voltage when the packets
are generated. A change of voltage probably  changes the frequency
of some clock slightly, thus generating FSK (F1A to be exact).

On the one raspberry pi:

killall dhcpcd #disable any other software messing with the eth0 interface, such as NetworkManager

ifconfig eth0 192.168.1.1 netmask 255.255.255.0
route add -net 192.168.1.0/24 dev eth0 #not sure why ifconfig doesn't set the route

On the other raspberry pi:

killall dhcpcd #disable any other software messing with the eth0 interface, such as NetworkManager

ifconfig eth0 192.168.1.2 netmask 255.255.255.0
route add -net 192.168.1.0/24 dev eth0 #not sure why ifconfig doesn't set the route

ping 192.168.1.1 #verify you have connectivity

./etherify2.sh /tmp/secret.txt  #to leak out the contents of /tmp/secret.txt
./etherify2.sh                  # or just to send the standard text




#######################################################

Both were tested on 2 raspberry pi 4 connected together via a 2m 
ethernet cable included in the raspberry pi starter kit. The choice of
hardware was done so that it would be simple to reproduce it anywhere.
The tests were also done with other hardware, etherify1.sh works with most
hardware, etherify2.sh works only with some.

Please tune the receiver to around 125MHz in CW mode with a
very narrow filter. Sometimes AM mode can also be used. The tests 
were performed with a Yaesu FT-817 receiver with a 500Hz CW filter 
(cw decoded by ear), and with and SDR receiver using an rtl-sdr dvb-t 
dongle, with gqrx as the receiver and fldigi as the morse decoder (or
decoded by ear).
 
During tests etherify1.sh could be received at a distance of 100m,
and etherify2.sh could be received at a distance of 30m.

Notice:
- conduct the tests in an electromagnetically quiet area
- software decoders are very bad at decoding morse code in the presence
  of interference, and with imperfect timing. If you want to assess if the
  signal is decodable, then get someone who can receive by ear
  (such as an experienced amateur radio operator).
  Humans are way better at this.
- run this as root (etherify2.sh could be made to run non-root with udp)
- please read https://lipkowski.com/etherify for further reading

