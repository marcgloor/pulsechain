docker run -it \
  --net=host \
  --name=validatorkeys \
  -v /mnt/pulsechain/prod:/blockchain \
  registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest \
  accounts import \
  --pulsechain \
  --keys-dir=/blockchain/validator_keys \
  --wallet-dir=/blockchain/consensus/validator
