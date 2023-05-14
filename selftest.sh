#!/bin/ksh
# 08/06/2003 - written by Marc O. Gloor <marc.gloor@alumni.nus.edu.sg>
# Use this selftest scripts with care and just use what makes sense to you!
#
# Note: Generally, a firewall is a permanent work in progress, a continous improvement effort
# This wip version was a quick and dirty hack taken from an existing server to
# suit the needs of hardening a pulsechain validator mainnet node.
# Report any issues, hints or suggestions to me and I will update this git branch accordingly
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
#
#


echo -n "Performing latency check (y/[n]): "
  read simu
    case "$simu" in
    y) echo "Bandwith latency check: " ; /usr/bin/speedtest-cli --simple ;;
    n) echo "Proceeding without bandwith throughput selftest..." ;;
    *) echo "Proceeding without bandwith throughput selftest..." ;;
    esac;

echo
 
echo "ZFS pool must be ONLINE: "
zpool list 

echo 

echo "ZFS pool must mounted: "
zpool status

echo 

echo "ZFS datasets listing: "
zfs list

echo

echo "Timesync system service status:"
systemctl list-units -t service |  grep 'systemd-timesyncd.service' 

#echo
#echo "System clock synchronization:"
#timedatectl

echo

echo "System root disk temperature:"
hddtemp /dev/sdc

echo 

echo "Validator disks temperature:"
#hddtemp  
echo "<Placeholder>"

echo 
 
echo "Validator snapshots available:"
#ls -1 /mnt/pulsechain/snapshots/
zfs list -t snapshot

echo

echo "Validator sync status: "
echo -n "Pulsechain chain sync status: " ; docker logs go-pulse 2>&1 | grep 'chain download' | tail -n 1 |  awk '/chain download/ {print $8}' | tr -d 'synced='
echo -n "Pulsechain state sync status: " ; docker logs go-pulse 2>&1 | grep 'state download' | tail -n 1 |  awk '/state download/ {print $8}' | tr -d 'synced='
curl -s http://localhost:8545 -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":67}" | jq


