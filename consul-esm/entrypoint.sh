#!/bin/sh
set -e

# You can also set the ESM_LOCAL_CONFIG environment variable to pass some
# configuration JSON without having to bind any volumes.
if [ -n "$ESM_LOCAL_CONFIG" ]; then
	echo "$ESM_LOCAL_CONFIG" > "/etc/consul-esm.d/local.json"
fi

exec "$@"
