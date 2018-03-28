ARG DPDK_VERSION

FROM ubuntu:xenial

ENV VERSION ${DPDK_VERSION:-17.08.1}
ENV RTE_SDK /opt/dpdk/dpdk-stable-${VERSION}
ENV RTE_TARGET build
ENV RTE_ARCH x86_64

RUN apt-get update && apt-get install -y \
    build-essential \
    libnuma-dev \
    libpcap-dev \
    pciutils \
    python \
    python3 \
    wget && \
    rm -rf /var/lib/apt /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/dpdk

WORKDIR /opt/dpdk

RUN wget --no-check-certificate https://fast.dpdk.org/rel/dpdk-$VERSION.tar.xz && \
    tar xf dpdk-$VERSION.tar.xz && \
    rm dpdk-$VERSION.tar.xz

WORKDIR $RTE_SDK

COPY dpdk/common_linuxapp-17.08.container $RTE_SDK/config/common_linuxapp
RUN ln -s $RTE_SDK/ /dpdk && make config T=x86_64-native-linuxapp-gcc
RUN make all
