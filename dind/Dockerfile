#
# Docker in Docker to emulate an isolated node in containernet
# that can host multiple sub containers with docker compose
#
FROM docker:stable-dind

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG COMPOSE
ARG GLIBC=2.28-r0

ENV COMPOSE_FILE=/etc/docker-compose.yml

RUN apk update \
  && apk add \
    bash \
    ca-certificates \
    curl \
    ethtool \
    ip6tables \
    iptables \
    iputils \
    less \
    libgcc \
    net-tools \
    openssl \
    procps \
    tcpdump \
    vim \
  # installs the glibc dependency docker compose needs to run on alpine
  && curl -sSfL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    -o /etc/apk/keys/sgerrand.rsa.pub \
  && curl -sSfL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC/glibc-$GLIBC.apk \
    -o glibc-$GLIBC.apk \
  && apk add glibc-$GLIBC.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-$GLIBC.apk \
  && rm -rf /var/cache/apk/* \
  && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
  && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib/ \
  && ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib/ \
  && curl -sSfL https://github.com/docker/compose/releases/download/$COMPOSE/docker-compose-Linux-x86_64 \
    -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD []
