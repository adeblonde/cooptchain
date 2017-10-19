#!/bin/bash

cd $TOOLS_DIR/dockers/Compile
sudo docker build -t compile .
cd $WORK_DIR

NGINX_DOCROOT=/var/www/cooptchain
# NGINX_DOCROOT=$WORK_DIR

sudo docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" --entrypoint=npm compile install

sudo docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" --entrypoint=npm compile run build

[ -f $NGINX_DOCROOT ] || mkdir -p $NGINX_DOCROOT
sudo rsync -av src/ $NGINX_DOCROOT
sudo rsync -av node_modules $NGINX_DOCROOT

sudo chown -R www-data. $NGINX_DOCROOT
