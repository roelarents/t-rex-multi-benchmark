FROM pdok/lighttpd:1.4.67 AS service

ARG trex_version=0.14.3

USER root

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Amsterdam

RUN apt update && apt install -y \
    libssl1.1 \
    gdal-bin \
    libgdal20 \
    curl

# FOR DEV ONLY
RUN apt install -y procps
###

RUN apt-get clean

RUN export $(cat /etc/os-release | grep VERSION_CODENAME) && \
    curl -O -L https://github.com/t-rex-tileserver/t-rex/releases/download/v${trex_version}/t-rex_${trex_version}-1.${VERSION_CODENAME}_amd64.deb && \
    dpkg -i t-rex_${trex_version}-1.${VERSION_CODENAME}_amd64.deb && \
    rm t-rex_*_amd64.deb

ADD --chmod=777 config/lighttpd.conf /srv/lighttpd/lighttpd.conf
ADD config/include.conf /srv/lighttpd/include.conf
ADD startup-lighttpd-trex.sh /startup-lighttpd-trex.sh

USER www

# WORKDIR /var/data/in

VOLUME ["/var/data/in"]
VOLUME ["/var/data/out"]

EXPOSE 80
EXPOSE 6767

ENV PROCESS_COUNT=1
ENV THREAD_COUNT=1
ENV CONCURRENCY_TYPE=""

ENTRYPOINT ["/startup-lighttpd-trex.sh"]
