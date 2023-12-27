#!/bin/ksh

cd /mnt/pulsechain/prod

# Stop all the detached monitors
killall nmon iptraf bash tail speedometer > /dev/null 2>&1
kill $(pgrep -f "/usr/bin/SCREEN -S f\) PROC MONITOR -dm bashtop") > /dev/null 2>&1


