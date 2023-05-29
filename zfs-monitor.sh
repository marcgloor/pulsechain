#!/bin/ksh

clear
while true; do
  if zpool status | grep -q "OFFLINE"; then
    echo "ALERT: Zpool OFFLINE" | figlet -w 130
    zpool status
  else
    echo "pool0:  ONLINE" | figlet -w 130
  fi
  sleep 1m  # Adjust the sleep interval as needed
  clear
done

