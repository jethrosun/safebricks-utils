FROM alpine:latest

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG CONSUL_ESM

RUN apk update \
  && apk add \
    ca-certificates \
    curl \
  && mkdir -p /tmp/build \
  && cd /tmp/build \
  && curl -sSfL https://releases.hashicorp.com/consul-esm/${CONSUL_ESM}/consul-esm_${CONSUL_ESM}_linux_amd64.zip \
    -o consul-esm_${CONSUL_ESM}_linux_amd64.zip \
  && unzip consul-esm_${CONSUL_ESM}_linux_amd64.zip \
  && cp consul-esm /usr/local/bin \
  && cd /tmp \
  && rm -rf /tmp/build \
  && apk del \
    ca-certificates \
    curl \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /etc/consul-esm.d

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["consul-esm", "-config-dir", "/etc/consul-esm.d"]
