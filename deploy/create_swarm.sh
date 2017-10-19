### Environment setup

### get terraform on path for the session's duration
export PATH=/usr/local/terraform/bin:$PATH
. ~/.bashrc

### parameters
export TASK=test_cooptchain
export WORK_DIR=$HOME/workspace/$TASK
export TOOLS_DIR=$HOME/workspace/CooptChain
export SSH_KEY=$TOOLS_DIR/SSH_NOVNCHAIN.pem

### Choose infrastructure (uncomment only one)
export INFRA=aws_free_tier; export AWS=ON
# export INFRA=bare_metal; USER=cooptchain_admin
# export INFRA=aws_m4x_spot; USER=ec2-user
# export INFRA=azure; USER=cooptchain_admin

### Choose configuration (with or without Docker, uncomment only one)
export CONFIG=config_cooptchain
# export CONFIG=config_cooptchain_docker

### parse AWS credential file
export AWS_CREDENTIAL_FILE=$HOME/workspace/aws_creds.txt
IFS=: read user access_key secret_key docker_repo ssh_key < $AWS_CREDENTIAL_FILE
export USER=$user
export AWS_ACCESS_KEY=$access_key
export AWS_SECRET_KEY=$secret_key
export AWS_DOCKER_REPO_ID=$docker_repo
export SSH_KEY_ID=$ssh_key

export MONGO_USER="mongo_cooptchain"

echo $USER $AWS_ACCESS_KEY $AWS_SECRET_KEY $AWS_DOCKER_REPO_ID $SSH_KEY $SSH_KEY_ID
### prepare work folders
mkdir -p $WORK_DIR

cd $WORK_DIR
cp -R $TOOLS_DIR/models/${INFRA}_config.tf .
cp $TOOLS_DIR/SSH_NOVNCHAIN.pem .
sed -ie "s#SECRET_ACCESS_KEY#${AWS_SECRET_KEY}#g" ${INFRA}_config.tf
sed -ie "s/ACCESS_KEY/${AWS_ACCESS_KEY}/g" ${INFRA}_config.tf
sed -ie "s/SSH_KEY/${SSH_KEY_ID}/g" ${INFRA}_config.tf

cp -R $TOOLS_DIR/playbooks .
cp -R $TOOLS_DIR/dockers .
cp $TOOLS_DIR/config_startup.txt .

# rm *.ini
# 
# ### prepare Dockers
# $TOOLS_DIR/shutils/prepare_docker_repo.sh
# 
# ### create hosts
# python $TOOLS_DIR/swarm.py --terraform-file ${INFRA}_config.tf --task-file config_startup.txt --working-folder $WORK_DIR --task-name $TASK --log-file log_$TASK.txt --ssh-key $SSH_KEY
# 

# ### prepare initial parameters for miner setup
# mkdir -p startup
# while IFS=\  read node_name node_ip
# do
#   if [ "$node_ip" != "" ]
#   then
#     cp $TOOLS_DIR/startup/launch_miner_template.sh startup/launch_miner_${node_name}.sh
#     sed -i "s#IDENTITY#${node_name}#g" startup/launch_miner_${node_name}.sh
#   fi
# done < host_cooptchain_miner_${TASK}.ini

# ## add data to running instances (just in case) :
$TOOLS_DIR/shutils/push_data.sh
# 
# ## prepare VMs :
# 
# ## launch task on all hosts
# /usr/local/bin/ansible-playbook -i hosts_${TASK}.ini -u $USER playbooks/playbook_config_all_host.yml --private-key=$SSH_KEY
# 
# ## configure by VM type
# for type in cooptchain_miner cooptchain_admin cooptchain_database cooptchain_mix
# do
#   echo "/usr/local/bin/ansible-playbook -i host_${type}_${TASK}.ini -u $USER playbooks/playbook_config_${type}.yml --private-key=$SSH_KEY"
#   /usr/local/bin/ansible-playbook -i host_${type}_${TASK}.ini -u $USER playbooks/playbook_config_${type}.yml --private-key=$SSH_KEY
# done

