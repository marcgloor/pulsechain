docker run \
  --restart always \
  --net=host \
  --name=validator \
  -v /mnt/pulsechain/prod:/blockchain \
  registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest \
  --pulsechain \
  --beacon-rpc-provider=127.0.0.1:4000 \
  --wallet-dir=/blockchain/consensus/validator \
  --wallet-password-file=/blockchain/password.txt \
  --datadir=/blockchain/consensus \
  --suggested-fee-recipient=<your-public-eth-pulsechain-wallet-address-here> \
  --graffiti <your-tag-here>
