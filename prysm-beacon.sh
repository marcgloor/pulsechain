docker run \
  --restart always \
  --net=host \
  --name=prysm \
  -v /mnt/pulsechain/prod:/blockchain \
  registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest \
  --pulsechain \
  --jwt-secret=/blockchain/jwt.hex \
  --datadir=/blockchain/consensus \
  --execution-endpoint=http://127.0.0.1:8551 \
  --checkpoint-sync-url=https://checkpoint.pulsechain.com \
  --genesis-beacon-api-url=https://checkpoint.pulsechain.com \
  --suggested-fee-recipient=<your-public-eth-pulsechain-wallet-address-here> \
  --p2p-host-ip=$(curl -s ident.me) \
  --min-sync-peers=1
