#!/bin/sh

screen -S "d) SYST MONITOR" -d -m nmon
screen -S "e) PROC MONITOR" -d -m /usr/bin/bashtop
screen -S "f) NETW MONITOR" -d -m speedometer -l -r eno1 -m $(( 1024 * 1024 * 3 / 2 ))
screen -S "g) DISK MONITOR" -d -m tail -n 25 -f /var/log/pulsechain-df.log
