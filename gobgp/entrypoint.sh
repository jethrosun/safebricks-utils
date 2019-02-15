#!/bin/sh
set -e

# You can also set the GOBGP_LOCAL_CONFIG environment variable to pass some
# configuration TOML without having to bind any volumes.
if [ -n "$GOBGP_LOCAL_CONFIG" ]; then
	echo "$GOBGP_LOCAL_CONFIG" > "/etc/gobgpd.conf"
fi

exec "$@"
