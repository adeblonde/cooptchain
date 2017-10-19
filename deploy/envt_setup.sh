#!/bin/bash

### install Azure CLI
# sudo apt-get update && sudo apt-get install -y libssl-dev libffi-dev python-dev build-essential
# curl -L https://aka.ms/InstallAzureCli | bash

### install tools
sudo apt-get install python-pip coreutils -y
pip install --upgrade pip
pip install ansible
pip install argparse
pip install shlex
pip install python_terraform
pip install --upgrade --user awscli

### install terraform
wget https://releases.hashicorp.com/terraform/0.8.7/terraform_0.8.7_linux_amd64.zip
unzip terraform_0.8.7_linux_amd64.zip
sudo mkdir -p /usr/local/terraform/bin
sudo mv terraform /usr/local/terraform/bin
sudo chmod +x /usr/local/terraform/bin/terraform

export PATH=/usr/local/terraform/bin:$PATH
. ~/.bashrc
 
### install docker
sudo apt-get install docker.io -y

### install Golang
sudo apt-get install golang
export GOPATH=/home/vainamoinen/workspace/go
mkdir -p $GOPATH

### install npm
sudo apt-get install npm
sudo npm install typescript -g
if [ ! -e /usr/bin/node ]
then
  sudo ln -s /usr/bin/nodejs /usr/local/bin/node
fi

### install maven
sudo apt-get install maven -y

### generate RSA public Key
ssh-keygen -t rsa
### (remember passphrase)

### create SSH-agent
ssh-agent | sh

ssh-add

### reenter passphrase
