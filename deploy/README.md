CooptChain project Official release :)


Started a wiki : https://git.cooptchain.com/blockchain/CooptChain/wikis/home 

## Build the docker image automatically

```bash
docker build -t ethereum .
```

## Start the container

```bash
# In CooptChain repo
git pull

docker run -it --rm -v ${PWD}:/CooptChain -h 'miner_1' ethereum /bin/bash
```

## Create the first genesis block

Create /CooptChain/genesis.json file.

```bash
bash /CooptChain/create_genesis_block.sh <PASSWORD>
```

## Set up miner environment

Initialize the node with the /CooptChain/genesis.json file.

Add the enode to the /CooptChain/static-nodes.json file.

Create a static link from the /CooptChain/static-nodes.json file into the DATADIR folder.

```bash
bash /CooptChain/create_miner.sh <PASSWORD>
```

## Create a cluster of nodes

On your Linux home machine, run the envt_setup.sh script :
```
./envt_setup.sh
```

This script install pip (a package manager for python), several python packages, Ansible, the Terraform software that allows to create machines on the cloud (or on local VMs), npm (nodeJS package manager). 
It will also help you to create a SSH key with a passphrase, and a ssh agent that allows ssh connection without reentering the passphrase all times

Then, run the create_swarm script : globally, this script create a specific folder, containing a bunch of intermediate files, then switch on machines on AWS (or any other cloud), push data on these machines, run a few ansible scripts to configure them, in order to setup a working network of cooptchain miners, with an admin node and a database node.

create_swarm will use the following utils :

https://docs.ansible.com/ansible/index.html

https://www.terraform.io/docs/index.html

https://docs.docker.com/

https://tomcat.apache.org/tomcat-8.0-doc/index.html

https://nginx.org/en/docs/

https://docs.npmjs.com/

Let us see this script in details.
First, you need to specify in the script some parameters :

```
export TASK=test_cooptchain
```
The TASK parameter will be the name of the project (and the name of the specific folder created)

```
export WORK_DIR=$HOME/workspace/$TASK
```
The WORK_DIR parameter will be the folder containing intermediate files, such as list of IPs for the nodes, copies of Ansible playbooks, and so on. By default, it will be in the folder "workspace" of your home

```
export TOOLS_DIR=$HOME/workspace/CooptChain

```
The TOOLS_DIR parameter will be the folder containing the git repository locally on your machine. By default, we assume you cloned the git into your home/workspace directory

```
export INFRA=aws_free_tier; export AWS=ON

```
The INFRA and AWS parameter allow you to choose what kind of cloud, how many machines and what kind of machines you want for your cluster. The create_swarm script will choose a Terraform configuration file correspondding to your choice into the 'models' folder.

For more information on Terraform configurations and available cloud providers, see : https://www.terraform.io/docs/providers/

```
export CONFIG=config_cooptchain

```
The CONFIG parameter allows you to choose if you want to deploy your cluster using Dockers, or directly on the machines created by Terraform

```
### parse AWS credential file
```
If using AWS, you will need to provide the script with a credential file containing your connection information.

The create_swarm script will copy the default SSH key of the project (but you can provide any personal SSH key for setting up your own cluster). It will copy other files too.

```
### prepare Dockers
$TOOLS_DIR/shutils/prepare_docker_repo.sh
```
If we want to use dockers, we go through the dockers folder, we build successively all the dockers for all the kind of machines we want (miners, admin, database, mix), and push them on an AWS docker repository publicly available

```
### create hosts
# python $TOOLS_DIR/swarm.py --terraform-file ${INFRA}_config.tf --task-file config_startup.txt --working-folder $WORK_DIR --task-name $TASK --log-file log_$TASK.txt --ssh-key $SSH_KEY
```
We use the 'swarm' python tool, that wrap Terraform, to create a cluster of machines.

We use swarm as follows : 

a Terraform .tf file containing the configuration we want

a task file that will launch a queue of tasks on the machines created

the location of the working folder that will receives .txt files listing the IPs of the created machines

the location of the log file

the location of the SSH key used for communication

```
## add data to running instances (just in case) :
$TOOLS_DIR/shutils/push_data.sh
```
We clone the git repository of the CooptChain-Web project, then we prepare and send data to the hosts, especially :

the AWS credential files (to allow to connect to the Docker repository)

create_genesis_block and create_miner scripts

tomcat configuration file (not used yet)

nginx configuration file

the cooptchain-front folder and its content, once it has been built by npm

```
/usr/local/bin/ansible-playbook -i host_${type}_${TASK}.ini -u $USER playbooks/playbook_config_${type}.yml --private-key=$SSH_KEY
```
Then finally, we can apply the ansible playbooks to the corresponding machines
