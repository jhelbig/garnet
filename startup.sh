#!/bin/bash

if [ ! -z "$(pidof redis-server)" ]; then
  kill -9 "$(pidof redis-server)"
fi

while [ ! -z "$(ps -ef | grep garnet | egrep -v "grep")" ]
do
  echo "killing garnet processes"
  ps -ef | grep garnet | egrep -v "grep" | awk '{ system("kill -9 " $2) }'
  sleep 5
done

if [ "$GARNET_REDIS_HOST" == "0.0.0.0" ]; then
  envsubst < /usr/share/project/redis.conf.template > /etc/redis/redis.conf
  redis-server /etc/redis/redis.conf --daemonize yes
else
  echo "Skipping Redis setup, please make sure that connections to $GARNET_REDIS_HOST can be made from this host!"
fi

echo "Starting $APP_ENV"
if [ "$APP_ENV" == "dev" ]; then
  crystal run src/garnet.cr -- -s downloader &
  sleep 1
  crystal run src/garnet.cr -- -s usher &
  sleep 1
  crystal run src/garnet.cr -- -s web
else
  garnet -s downloader &
  sleep 1
  garnet -s usher &
  sleep 1
  garnet -s web
fi
