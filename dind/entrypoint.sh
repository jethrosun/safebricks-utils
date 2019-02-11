#!/bin/bash
set -e

sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.ipv6.conf.default.seg6_enabled=1
sysctl -w net.ipv6.conf.default.accept_source_route=1
sysctl -w net.ipv6.conf.all.accept_source_route=1
sysctl -w net.ipv6.conf.default.accept_ra=2
sysctl -w net.ipv6.conf.all.accept_ra=2

# copied from https://github.com/docker-library/docker/blob/master/18.09/dind/dockerd-entrypoint.sh
# no arguments passed
# or first arg is `-f` or `--some-option`
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    # add our default arguments
    set -- dockerd \
        --host=unix:///var/run/docker.sock \
        --host=tcp://0.0.0.0:2375 \
        "$@"
fi

if [ "$1" = 'dockerd' ]; then
    # if we're running Docker, let's pipe through dind
    set -- "$(which dind)" "$@"

    # explicitly remove Docker's default PID file to ensure that it can start properly if
    # it was stopped uncleanly (and thus didn't clean up the PID file)
    find /run /var/run -iname 'docker*.pid' -delete
fi

exec "$@"
