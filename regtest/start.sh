#!/bin/bash

data_path=$(<data_path)
if [ -n "$data_path" ]; then
  echo "Start up esplora docker container with data path: $data_path ..."
  pid=`docker ps | grep "[b]lockstream/esplora" | awk '{print $1}'`
  if [ -n "$pid" ]; then
    echo "esplora client already running"
  else
    docker run -d -p 50001:50001 -p 8094:80 \
        --volume "$data_path/esplora-bitcoin-regtest-data:/data" \
        --rm -i -t blockstream/esplora \
        bash -c "sed -i '182i echo \"acceptnonstdtxn=1\" >> /data/.bitcoin.conf' /srv/explorer/run.sh && \
                sed -i '/http {/a \    client_max_body_size 100M;' /etc/nginx/nginx.conf && \
                /srv/explorer/run.sh bitcoin-regtest explorer"

    echo "Waiting for esplora start up (10s) ..."
    sleep 10
  fi

  pid=`ps | grep "[b]lock-generator" | awk '{print $1}'`
  echo "Start up block miner ..."
  if [ -n "$pid" ]; then
    echo "block-generator.sh already running"
  else
    nohup ./block-generator.sh &
  fi
else
  echo "Run install.sh first"
fi
