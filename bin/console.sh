#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
cd $DIR/server
export memory_limit=512M
export APP_ENV=prod
export PATH=$PATH:$DIR/bin
${DIR}/bin/php.sh bin/console "$@"
