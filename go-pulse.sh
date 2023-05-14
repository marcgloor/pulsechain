docker run \
  --stop-timeout=180 \
  --restart always \
  --net=host \
  --name=go-pulse \
  -v /mnt/pulsechain/prod:/blockchain \
  registry.gitlab.com/pulsechaincom/go-pulse:latest \
  --pulsechain \
  --authrpc.jwtsecret=/blockchain/jwt.hex \
  --datadir=/blockchain/execution \
  --http
