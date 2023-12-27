#!/bin/sh

clear
echo "Geth sync status (result=false, you are fully sync'd):"

curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq

echo
echo "Geth sync status (currentBlock = highest Block, you are fully sync'd):"

curl -s http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":67}' | jq | egrep 'current|highest'

echo 
