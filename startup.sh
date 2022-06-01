#!/bin/sh

if [ ! -z "$(pidof nginx)" ]; then
  echo "killing nginx server"
  nginx -s stop
fi

while [ ! -z "$(ps -ef | grep garnet | egrep -v "grep")" ]
do
  echo "killing garnet processes"
  ps -ef | grep garnet | egrep -v "grep" | awk '{ system("kill -9 " $2) }'
  sleep 2
done

if [ ! -z "$(pidof redis-server)" ]; then
  echo "killing redis server"
  kill -9 "$(pidof redis-server)"
  sleep 2
fi


if [ "$GARNET_REDIS_HOST" == "0.0.0.0" ]; then
  echo "starting garnet redis server on $GARNET_REDIS_HOST"
  envsubst < /usr/share/project/redis.conf.template > /etc/redis.conf
  redis-server /etc/redis.conf --daemonize yes
else
  echo "Skipping Redis setup, please make sure that connections to $GARNET_REDIS_HOST can be made from this host!"
fi

echo "Configuring and starting nginx"
envsubst < /usr/share/project/default.conf.template > /etc/nginx/http.d/default.conf
nginx

echo "Starting $APP_ENV"
if [ "$APP_ENV" == "dev" ]; then
  crystal run src/garnet.cr -- -s downloader &
  sleep 1
  crystal run src/garnet.cr -- -s usher &
  sleep 1
  crystal run src/garnet.cr -- -s web
else
  garnet -s web &
  sleep 1
  garnet -s usher &
  sleep 1
  garnet -s downloader
fi
