#!/bin/sh

# If the first arg starts with a hyphen, prepend sbcl to arguments.
if [ "${1#-}" != "$1" ]; then
	set -- sbcl "$@"
fi

exec "$@"
