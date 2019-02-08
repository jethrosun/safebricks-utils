##
## compiling tcpreplay from source
##

FROM bitnami/minideb:stretch as tcpreplay

ARG RELEASE=4.3.0

RUN install_packages \
    build-essential \
    ca-certificates \
    curl \
    file \
    libpcap-dev \
    tcpdump \
  && cd /tmp \
  && curl -sSfL https://github.com/appneta/tcpreplay/releases/download/v${RELEASE}/tcpreplay-${RELEASE}.tar.xz | tar -xJv \
  && cd tcpreplay-${RELEASE} \
  # replace the occurrences of ETH_P_ALL with ETH_P_IP
  && sed -i 's|ETH_P_ALL|'"ETH_P_IP"'|g' src/common/sendpacket.c \
  && ./configure \
  && make \
  && make install


##
## development image with DPDK and Rust
##

FROM williamofockham/dpdk:17.08.1

LABEL maintainer="williamofockham <occam_engineering@comcast.com>"

ARG RUSTUP_TOOLCHAIN
ARG BACKPORTS_REPO=/etc/apt/sources.list.d/stretch-backports.list
ARG IOVISOR_REPO=/etc/apt/sources.list.d/iovisor.list

ENV PATH=$PATH:/root/.cargo/bin
ENV LD_LIBRARY_PATH=/opt/netbricks/target/native:$LD_LIBRARY_PATH
ENV CARGO_INCREMENTAL=0
ENV RUST_BACKTRACE=1

COPY --from=tcpreplay /usr/local/bin /usr/local/bin
COPY --from=tcpreplay /usr/local/share/man/man1 /usr/local/share/man/man1

RUN install_packages \
  # clang, libclang-dev and libsctp-dev are netbricks deps
  # cmake, git and libluajit-5.1-dev are moongen deps
  # libssl-dev and pkg-config are rust deps
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    gdb \
    gdbserver \
    git \
    libclang-dev \
    libcurl4-gnutls-dev \
    libgnutls30 \
    libgnutls-openssl-dev \
    libsctp-dev \
    libssl-dev \
    pkg-config \
    python-pip \
    python-setuptools \
    python-wheel \
    sudo \
    tcpdump \
  # pyroute2 and toml are agent deps
  && pip install \
    pyroute2 \
    toml \
  # install luajit 2.1.0-beta3 from stretch backports
  && echo "deb http://ftp.debian.org/debian stretch-backports main" > ${BACKPORTS_REPO} \
  && apt-get update -o Dir::Etc::sourcelist=${BACKPORTS_REPO} \
  && apt-get -t stretch-backports install -y --no-install-recommends libluajit-5.1-dev \
  # install bcc tools
  && echo "deb [trusted=yes] http://repo.iovisor.org/apt/xenial xenial-nightly main" > ${IOVISOR_REPO} \
  && apt-get update -o Dir::Etc::sourcelist=${IOVISOR_REPO} \
  && apt-get -t xenial-nightly install -y --no-install-recommends bcc-tools \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives \
  # install rust nightly and tools
  && curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUSTUP_TOOLCHAIN \
  && rustup component add \
    clippy-preview \
    rustfmt-preview \
    rust-src \
  # invoke cargo install independently otherwise partial failure has the incorrect exit code
  && cargo install cargo-watch \
  && cargo install cargo-expand \
  && cargo install hyperfine \
  && cargo install ripgrep \
  && cargo install sccache \
  && rm -rf /root/.cargo/registry

ENV RUSTC_WRAPPER=sccache

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
