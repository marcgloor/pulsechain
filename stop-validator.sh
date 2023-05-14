#!/bin/ksh

cd /mnt/pulsechain/prod

docker stop prysm go-pulse validator
docker rm prysm go-pulse validator

killall nmon tail > /dev/null 2>&1
docker container prune -f

docker ps -a
