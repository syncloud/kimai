#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
export COMPOSER_MEMORY_LIMIT=-1
export COMPOSER_ALLOW_SUPERUSER=1
expoet memory_limit=512M
exec $DIR/php/bin/php.sh -c /snap/kimai/current/config/php.ini "$@"
