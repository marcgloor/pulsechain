#!/bin/ksh

clear
while true; do
  if zpool status | grep -q "OFFLINE"; then
    echo "ZFS ARRAY:" | figlet -w 130
    echo "pool0:  OFFLINE" | figlet -w 130
    zpool status
    zpool iostat -v
  else
    echo "ZFS ARRAY:" | figlet -w 130
    echo "pool0:  ONLINE" | figlet -w 130
    echo 
    zpool status
    zpool iostat -v
  fi
  sleep 1m  # Adjust the sleep interval as needed
  clear
done

