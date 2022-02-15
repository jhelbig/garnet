#!/bin/bash

if [ "$GARNET_REDIS_HOST" == "0.0.0.0" ]; then
  envsubst < /usr/share/project/redis.conf.template > /etc/redis/redis.conf
  redis-server /etc/redis/redis.conf --daemonize yes
else
  echo "Skipping Redis setup, please make sure that connections to $GARNET_REDIS_HOST can be made from this host!"
fi

garnet -s downloader &
sleep 1
garnet -s usher &
sleep 1
garnet -s web
