#!/bin/sh

screen -S "d) SYST MONITOR      - Pulsechain Validator" -d -m nmon
screen -S "e) DISK MONITOR      - Pulsechain Validator" -d -m tail -f /var/log/pulsechain-df.log
screen -S "a) EXECUTION SERVER  - Pulsechain Validator" -m ./go-pulse.sh
screen -S "b) CONSENSUS SERVER  - Pulsechain Validator" -m ./prysm-beacon.sh
screen -S "c) VALIDATOR SERVER  - Pulsechain Validator" -m ./prysm-validator.sh
#screen -S "a) EXEC & CONS SERVER  -  Pulsechain Validator" -m /usr/bin/docker-compose -f /mnt/pulsechain/docker-compose-prysm.yml up
