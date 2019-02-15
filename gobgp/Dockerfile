FROM alpine:latest

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG GOBGP

RUN apk update \
  && apk add \
    ca-certificates \
    curl \
  && mkdir -p /tmp/build \
  && cd /tmp/build \
  && curl -sSfL https://github.com/osrg/gobgp/releases/download/v${GOBGP}/gobgp_${GOBGP}_linux_amd64.tar.gz | tar -xvz \
  && cp gobgp /usr/local/bin \
  && cp gobgpd /usr/local/bin \
  && cd /tmp \
  && rm -rf /tmp/build \
  && apk del \
    ca-certificates \
    curl \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gobgpd", "-f", "/etc/gobgpd.conf"]
