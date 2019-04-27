#!/bin/sh

set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- bsv_oneshot "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'bsv_oneshot' -a "$(id -u)" = '0' ]; then
	chown -R bitcoinsv .
	exec gosu bitcoinsv "$0" "$@"
fi

cd .bitcoin

pwd

ls -al

cd /bitcoinsv/.bitcoin/

ls -al

exec "$@"
