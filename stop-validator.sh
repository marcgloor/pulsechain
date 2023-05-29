#!/bin/ksh
# Gracefully shutdown (SIGTERM), terminate and cleanup the validator and the monitors

cd /mnt/pulsechain/prod

killall nmon tail speedometer > /dev/null 2>&1
docker stop go-pulse prysm validator
docker rm go-pulse prysm validator
docker container prune -f
docker ps -a
