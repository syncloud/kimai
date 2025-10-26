#!/bin/bash -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build/snap
#apt update
#apt install -y \
#  zip \
#  wget \
#  unzip \
#  --no-install-recommends

cd ${DIR}/../build
wget https://getcomposer.org/installer -O - -q | php -- --quiet
mv composer.phar /usr/local/bin/composer

mkdir $BUILD_DIR/server
wget --progress=dot:giga https://github.com/kimai/kimai/archive/refs/tags/$VERSION.tar.gz -O kimai.tar.gz
tar xf kimai.tar.gz --strip-components=1 -C $BUILD_DIR/server

cd $BUILD_DIR/server
export COMPOSER_MEMORY_LIMIT=-1

composer --no-ansi install --no-dev --optimize-autoloader
composer --no-ansi clearcache
composer --no-ansi require --update-no-dev laminas/laminas-ldap
 
SNAP=/snap/kimai/current
SNAP_DATA=/var$SNAP
mkdir -p bin
cp -r $DIR/bin/* bin

#sed -i 's###g' bin/console

rm -rf .env
ln -s $SNAP_DATA/config/.env .env
ln -s $SNAP_DATA/config/local.yaml config/packages/local.yaml

mv config/packages/monolog.yaml config/packages/monolog.yaml.dist
ln -s $SNAP_DATA/config/monolog.yaml config/packages/monolog.yaml

rm -rf var/cache
ln -s $SNAP_DATA/cache var/cache

rm -rf var/plugins
ln -s $SNAP_DATA/plugins var/plugins

