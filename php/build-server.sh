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
#composer config --global github-oauth.github.com $GITHUB_TOKEN
composer install --no-dev

SNAP=/snap/kimai/current
SNAP_DATA=/var$SNAP
mkdir -p bin
cp -r $DIR/bin/* bin

rm -rf .env
ln -s $SNAP_DATA/config/.env .env
