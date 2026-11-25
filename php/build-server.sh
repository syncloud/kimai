#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build/snap
SNAP_DATA=/var/snap/kimai/current

cd ${DIR}/../build
${DIR}/../download-retry.sh https://getcomposer.org/installer ${DIR}/../build/composer-setup.php
php ${DIR}/../build/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer

rm -rf ${BUILD_DIR}/server
mkdir ${BUILD_DIR}/server
${DIR}/../download-retry.sh https://github.com/kimai/kimai/archive/refs/tags/${VERSION}.tar.gz ${DIR}/../build/kimai.tar.gz
tar xf ${DIR}/../build/kimai.tar.gz --strip-components=1 -C ${BUILD_DIR}/server

cd ${BUILD_DIR}/server
export COMPOSER_MEMORY_LIMIT=-1
export COMPOSER_ALLOW_SUPERUSER=1

${DIR}/../retry.sh composer --no-ansi install --no-dev --optimize-autoloader
${DIR}/../retry.sh composer --no-ansi require --update-no-dev laminas/laminas-ldap
composer --no-ansi clearcache

rm -rf .env
ln -s ${SNAP_DATA}/config/.env .env
ln -s ${SNAP_DATA}/config/local.yaml config/packages/local.yaml

mv config/packages/monolog.yaml config/packages/monolog.yaml.dist
ln -s ${SNAP_DATA}/config/monolog.yaml config/packages/monolog.yaml

rm -rf var/cache
ln -s ${SNAP_DATA}/cache var/cache

rm -rf var/plugins
ln -s ${SNAP_DATA}/plugins var/plugins

rm -rf var/log
ln -s ${SNAP_DATA}/log var/log
