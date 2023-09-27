#!/bin/ksh

echo -n "Performing latency check (y/[n]): "
  read simu
    case "$simu" in
    y) echo "Bandwith latency check: " ; /usr/bin/speedtest-cli --simple --secure ;;
    n) echo "Proceeding without bandwith throughput selftest..." ;;
    *) echo "Proceeding without bandwith throughput selftest..." ;;
    esac;

echo
 
echo "ZFS pool must mounted and status ONLINE: "
zpool status
zpool iostat -v

echo

echo "Timesync system service status:"
systemctl list-units -t service |  grep 'systemd-timesyncd.service' 

#echo
#echo "System clock synchronization:"
#timedatectl

# sensors package install lm-sensors, dann sudo modprobe drivetemp

echo 

echo "CPU temperature: " ; sensors | grep -E "Core 0|Core 1"

echo

echo "System disk temperatures:"
echo -n "System root disk (SSD) : " ; sensors |  grep -A 2 "drivetemp-scsi-0-0" | tail -n 1
echo -n "ZFS pool disk 1 (SSD)  : " ; sensors |  grep -A 2 "drivetemp-scsi-1-0" | tail -n 1
echo -n "ZFS pool disk 2 (SSD)  : " ; sensors |  grep -A 2 "drivetemp-scsi-2-0" | tail -n 1
echo -n "System backp disk (HDD): " ; sensors |  grep -A 2 "drivetemp-scsi-3-0" | tail -n 1

echo 
 
echo "No. of validator snapshots available:"
#ls -1 /mnt/pulsechain/snapshots/
zfs list -t snapshot | wc -l

echo 

echo "Validator sync status: "
echo -n "Pulsechain chain sync status: " ; docker logs go-pulse 2>&1 | grep 'chain download' | tail -n 1 |  awk '/chain download/ {print $8}' | tr -d 'synced='
echo -n "Pulsechain state sync status: " ; docker logs go-pulse 2>&1 | grep 'state download' | tail -n 1 |  awk '/state download/ {print $8}' | tr -d 'synced='
curl -s http://localhost:8545 -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":67}" | jq
curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq | egrep 'current|highest'

echo

echo "Validator database size: "
tail -n 5 /var/log/pulsechain-df.log 

echo


