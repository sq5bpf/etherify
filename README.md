Etherify - bringing the ether back to ethernet

(c) 2020 Jacek Lipkowski SQ5BPF <sq5bpf@lipkowski.org>

2020 RC3 Conference talk: https://www.youtube.com/watch?v=7ek994-fwNE

Etherify 1 and 2: https://lipkowski.com/etherify (with RPI 4)
Etherify 3: https://lipkowski.com/etherify3/ (with no ethernet cable)
Etherify 4: https://lipkowski.com/etherify4/ (with dell laptops)
Etherify 5: https://lipkowski.com/etherify5/ (with ethernet switches)

These are attempts to transmit via leakage from ethernet.
For more info please read all of the articles on https://lipkowski.com/ AND see the RC3 Conference talk.


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




################################################################

etherify3.sh  - sends data wirelessly by changing the speed of an 
ethernet interface.

For more info see: https://lipkowski.com/etherify3

Usage:

./etherify3.sh <file>

If <file> is  given, then the contents are sent, else "etherify 3 demo" is sent.

This works by switching between 10Mbps and 100Mbps, which results
in a change of the electromagnetic radiation that leaks from the ethernet interface.
Switching to 100Mbps produces a signal at 125MHz, which is used to
transmit morse code.


Tested on a raspberry pi 4 running Raspbian 10 
without an ethernet connection, and powered via a powerbank.

ethtool eth0  #verify link is down

./etherify3.sh /tmp/secret.txt  #to leak out the contents of /tmp/secret.txt
./etherify3.sh                  # or just to send the standard text

Now i'm not sure if my particular Raspberry PI 4B leaks so much rf, or if this
is a general problem.


################################################################

etherify4.sh  - sends data wirelessly by changing the speed of an 
ethernet interface. This is an implementation for devices which
establish link after several seconds after changing the interface speed.

For more info see: https://lipkowski.com/etherify4

Usage:

./etherify4.sh <file>

If <file> is  given, then the contents are sent, else "etherify 4 demo" is sent.

This works by switching between 10Mbps and 100Mbps, which results
in a change of the electromagnetic radiation that leaks from the ethernet interface.
Switching to 100Mbps produces a signal at 125MHz, which is used to
transmit slow morse code.


Tested on two Dell Lattitude laptops (E6220 and D610) connected together via
a 2m ethernet cable. 


./etherify4.sh /tmp/secret.txt  #to leak out the contents of /tmp/secret.txt
./etherify4.sh                  # or just to send the standard text


The symbol length (dot length) is equal to the delay between changing link
speed and establishing link. This is usually several seconds. To receive
use any receiver capable of tuning to 125MHz and it's hsrmonics (integer multiples),
and pipe this into any software which is able to show a slow spectrogram.
Such software is used for example by amateur radio operators for QRSS CW
(slow morse code decoded visually). 

The sq5bpf_etherify4.usr file contains an example configuration for 
DL4YHF Spectrum Lab. When running under linux/wine the audio from 
the receiver (like gqrx) can be piped to Spectrum Lab via pulseaudio.

[![Watch the etherify 4 demo](https://img.youtube.com/vi/aHbgMt0w4Cc/hqdefault.jpg)](https://youtu.be/aHbgMt0w4Cc)

################################################################

etherify5.sh  - same as etherify4.sh, but transmits using network
devices (such as switches, routers) by changing the interface speed 
via SNMP.

For more info see: https://lipkowski.com/etherify5

Usage:

./etherify5.sh <file>

If <file> is  given, then the contents are sent, else "etherify 5 demo" is sent.

This works by switching between 10Mbps and 100Mbps, which results
in a change of the electromagnetic radiation that leaks from the network device.
This is used to transmit morse code.

This was tested on two Linksys LGS318 switches. Please edit the etherify5.sh
script to implement changing speed on your switch. Also please set the 
switch IP, port and type.

./etherify5.sh /tmp/secret.txt  #to leak out the contents of /tmp/secret.txt
./etherify5.sh                  # or just to send the standard text


The symbol length (dot length) is equal to the delay between changing link
speed and establishing link. This is usually several seconds, and can be set
in the script (the LINKDELAY parameter).
The signal can appear at different frequencies, depending on the switch hardware.
For example a Linksys LGS318 switch radiates a signal around 50MHz. 

Always test using two devices of the same type (because if two different devices are
used, then one would not know which one generates the radio signal).

Pipe the receiver audio into any software which is able to show a slow spectrogram.
Such software is used for example by amateur radio operators for QRSS CW
(slow morse code decoded visually). 

The sq5bpf_etherify4.usr file contains an example configuration for 
DL4YHF Spectrum Lab. When running under linux/wine the audio from 
the receiver (like gqrx) can be piped to Spectrum Lab via pulseaudio.

[![Watch the etherify 5 demo](https://img.youtube.com/vi/DK90gS4ZLxs/hqdefault.jpg)](https://youtu.be/DK90gS4ZLxs)

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

