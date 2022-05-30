FROM crystallang/crystal:latest

ENV GARNET_HTTP_PORT=8080
ENV GARNET_REDIS_HOST=0.0.0.0
ENV GARNET_REDIS_PORT=6379
ENV GARNET_REDIS_PASSWORD=c9f6aae089d3a690_garnet_change_me_ab76f7a61366a0d0
ENV GARNET_REDIS_NAMESPACE=GARNET_YTDL
ENV GARNET_NOTIFY_QUEUE=garnet_notify
ENV GARNET_DOWNLOADER_SLEEP=30
ENV GARNET_CORS_ORIGIN_ALLOW="*"

# install youtube-dl pre-reqs
RUN apt-get update -y && \
    apt-get install -y python ffmpeg redis gettext-base && \
    apt-get clean

# install youtube-dl
ADD https://yt-dl.org/downloads/latest/youtube-dl /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl

ADD . /usr/share/project

WORKDIR /usr/share/project

RUN shards install && \
    echo "Building Garnet binaries" && \
    crystal build /usr/share/project/src/garnet.cr --release --progress -o /usr/bin/garnet && \
    echo "Cleanup" && \
    rm -fR /usr/share/project/lib /usr/share/project/src /usr/share/project/shard.*

ENTRYPOINT "/usr/share/project/startup.sh"