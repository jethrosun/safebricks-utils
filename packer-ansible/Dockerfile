FROM hashicorp/packer:1.3.4
LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG ANSIBLE_VERSION

RUN set -x \
    \
    && echo "==> Adding build-dependencies..." \
    && apk update && apk upgrade               \
    && apk add --virtual build-dependencies    \
         gcc         \
         musl-dev    \
         libffi-dev  \
         openssl-dev \
         make        \
         python-dev  \
    \
    && echo "==> Adding Python runtime..."     \
    && apk add --no-cache py-pip bash          \
    && pip install --upgrade pip               \
    && echo "====> Installing ansible..."      \
    && pip install docker                      \
    && pip install ansible==${ANSIBLE_VERSION} \
    && apk del build-dependencies              \
    && rm -rf /var/cache/apk/*                 \
    \
    && echo "===> Adding hosts for convenience..." \
    && mkdir -p /etc/ansible                       \
    && echo 'localhost' > /etc/ansible/hosts

ENTRYPOINT []
CMD [ "/bin/bash" ]
