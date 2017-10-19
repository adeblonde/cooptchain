#!/bin/bash

docker build -t DOCKER_NAME:DOCKER_LABEL . 
docker tag DOCKER_NAME:DOCKER_LABEL AWS_DOCKER_REPO_ID:DOCKER_LABEL 

aws ecr get-login --region eu-west-1  | sh

docker push AWS_DOCKER_REPO_ID:DOCKER_LABEL  
