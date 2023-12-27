#!/bin/ksh
# @(#) Pulsechain validator selftest script
# $Id: selftest.sh,v 1.18 2023/12/27 07:08:57 root Exp $
# 2023/4/8 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

echo "Pulsechain validator selftest launched..."
echo

output=$(/usr/bin/speedtest-cli --simple --secure)

if [ "`pgrep  -f "EXECUTION SERVER"`" != '' ]; then
   echo "GETH Execution Server    : up & running"
  else
   echo "GETH Execution Server    : halted"
fi

if [ "`pgrep  -f "CONSENSUS SERVER"`" != '' ]; then
   echo "PRYSM Consensus Beacon   : up & running"
  else
   echo "PRYSM Consensus Beacon   : halted"
fi

if [ "`pgrep  -f "VALIDATOR SERVER"`" != '' ]; then
   echo "PRYSM Validator Server   : up & running"
  else
   echo "PRYSM Validator Server   : halted"
fi
 
if [ "`pgrep  -f "EXECUTION SERVER"`" != '' ]; then
   echo "Validator uptime         : $(ps -p $(pgrep  -f "EXECUTION SERVER") -o etimes | tail -n1  | awk '{printf "%02dh %02dmin\n", int($1/3600), int(($1%3600)/60)}')"
  else
   echo "Validator uptime         : Validator is not running"
fi

echo "VCS system uptime        : $(ps -p $(pgrep  -f "init") -o etimes | tail -n1  | awk '{printf "%02dh %02dmin\n", int($1/3600), int(($1%3600)/60)}')"

echo -n "Timesync system status   : " ; systemctl list-units -t service | grep 'systemd-timesyncd.service' | awk '{ printf("%s %s %s\n", $2, $3, $4); }'
sync=$(timedatectl | grep "clock synchronized")
echo "$sync"
echo "System date (Stratum 1)  : $(date --utc)"

# Use tail to extract the last two lines
last_two_lines=$(echo "$output" | tail -n 2)

# Use head to split the last two lines into separate variables
line1=$(echo "$last_two_lines" | head -n 1 | tr -d "Download: ")
line2=$(echo "$last_two_lines" | tail -n 1 | tr -d "Upload: ")

# Display the contents of the variables
echo "Bandwith download speed  : $line1"
echo "Bandwith upload speed    : $line2"

# sensors package install lm-sensors, dann sudo modprobe drivetemp
#echo -n "CPU Core 0 temperature   : " ; sensors | grep -E "Core 0" | tail -n 2 | awk -F':' '{print $2}' | awk '{print $1}'
#echo -n "CPU Core 1 temperature   : " ; sensors | grep -E "Core 1" | tail -n 2 | awk -F':' '{print $2}' | awk '{print $1}'
#echo -n "System root disk temp    : " ; sensors | grep -A 2 "drivetemp-scsi-0-0" | tail -n 1 | awk -F':' '{print $2}' | awk '{print $1}'
#echo -n "System backp disk temp   : " ; sensors | grep -A 2 "drivetemp-scsi-3-0" | tail -n 1 | awk -F':' '{print $2}' | awk '{print $1}'
#echo -n "ZFS pool status          : " ; zpool status | grep pool0 | tail -n 1 | sed 's/^[ \t]*//' | awk '{print $2}'
#echo -n "ZFS snapshots available  : " ; zfs list -t snapshot | wc -l
#echo -n "ZFS pool disk 1 temp     : " ; sensors | grep -A 2 "drivetemp-scsi-1-0" | tail -n 1 | awk -F':' '{print $2}' | awk '{print $1}'
#echo -n "ZFS pool disk 2 temp     : " ; sensors | grep -A 2 "drivetemp-scsi-2-0" | tail -n 1 | awk -F':' '{print $2}' | awk '{print $1}'

if [ "`docker logs go-pulse 2>&1 | grep 'chain download' | tail -n 1 |  awk '/chain download/ {print $8}' | tr -d 'synced='`" != '' ]; then
     echo -n "Chain sync status        : " ; docker logs go-pulse 2>&1 | grep 'chain download' | tail -n 1 |  awk '/chain download/ {print $8}' | tr -d 'synced='
  else
     echo "Chain sync status        : n/a "
fi

if [ "`docker logs go-pulse 2>&1 | grep 'state download' | tail -n 1 |  awk '/state download/ {print $8}' | tr -d 'synced='`" != '' ]; then
     echo -n "State sync status        : " ; docker logs go-pulse 2>&1 | grep 'state download' | tail -n 1 |  awk '/state download/ {print $8}' | tr -d 'synced='
  else
     echo "State sync status        : n/a "
fi

# Full sync status test queries, not included
#curl -s http://localhost:8545 -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":67}" | jq
#curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq | egrep 'current|highest'

echo -n "Validator database size  : " ; tail -n 5 /var/log/pulsechain-df.log | tail -n 1 | awk '$0 {print $5}' | tr -d '.'
echo

