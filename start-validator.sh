#!/bin/sh

cd /mnt/pulsechain/prod/bin
screen -S "a) EXECUTION SERVER" -m ./go-pulse.sh
screen -S "b) CONSENSUS SERVER" -m ./prysm-beacon.sh
screen -S "c) VALIDATOR SERVER" -m ./prysm-validator.sh
#./start-monitors.sh
#screen -S "a) EXEC & CONS SERVER  -  Pulsechain Validator" -m /usr/bin/docker-compose -f /mnt/pulsechain/docker-compose-prysm.yml up
