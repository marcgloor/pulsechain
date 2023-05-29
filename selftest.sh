#!/bin/ksh

echo -n "Performing latency check (y/[n]): "
  read simu
    case "$simu" in
    y) echo "Bandwith latency check: " ; /usr/bin/speedtest-cli --simple ;;
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

echo

echo "System root disk temperature:"
hddtemp /dev/sda

echo

echo "Backup disk temperature:"
hddtemp /dev/sdd

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


