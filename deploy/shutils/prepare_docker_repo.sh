#!/bin/bash

cd $WORK_DIR/dockers

cd admin_docker
export DOCKER_NAME=cooptchain_node
export DOCKER_LABEL=admin
../shutils/build_docker.sh

cd ..

cd miner_docker
export DOCKER_NAME=cooptchain_node
export DOCKER_LABEL=miner
../shutils/build_docker.sh

cd ..

cd database_docker
export DOCKER_NAME=cooptchain_node
export DOCKER_LABEL=database
../shutils/build_docker.sh

cd ..

cd mix_docker
export DOCKER_NAME=cooptchain_node
export DOCKER_LABEL=mix
../shutils/build_docker.sh

cd ..