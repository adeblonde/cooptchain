#!/bin/bash

cd $WORK_DIR

### add credential files
if [ "${AWS}" == "ON" ]
then
	cp $TOOLS_DIR/aws_credentials_template.txt aws_credentials.txt
	sed -ie "s#AWS_ACCESS_KEY#${AWS_ACCESS_KEY}#g" aws_credentials.txt
	sed -ie "s#AWS_SECRET_KEY#${AWS_SECRET_KEY}#g" aws_credentials.txt
	
	cp $TOOLS_DIR/aws_config_template.txt aws_config.txt
fi

### copy locally files to send
# cp $TOOLS_DIR/tomcat.service .
# if [ -e NovNChain-Web ]; then sudo rm -R NovNChain-Web; fi
# git clone https://git.cooptchain.com/blockchain/NovNChain-Web.git NovNChain-Web
cp $TOOLS_DIR/nginx.conf .

### compile front website from sources using npm
# cd NovNChain-Web/cooptchain-front
# npm run build
cd NovNChain-Web/cooptchain-front
$TOOLS_DIR/dockers/Compile/compile_front.sh

### compile war 
cd $WORK_DIR/NovNChain-Web/Cooptthx
# mongo_creds_file="src/main/java/com/cooptchain/cooptthx/mongodb/DBConnectionHelper.java"
iconstants_file=src/main/java/com/cooptchain/cooptthx/IConstants.java
# cat $iconstants_file
sed -i "s/HOST=\"13.80.9.241\"/HOST=\"34.249.47.211\"/g" $iconstants_file
# sed -i "s/MONGODB_URI/${}/g" $mongo_creds_file
# mvn package
# mvn clean install -DskipTests

cd $WORK_DIR
for host in $(ls host_${TASK}_*.ini)
do
	ip_host=$(grep ansible_ssh_host $host | awk '{ print $2}' )
	ip_host=${ip_host#ansible_ssh_host=}
	echo "pushing script files to host "$ip_host
	
	### send geth startup files
# 	scp -i $SSH_KEY $TOOLS_DIR/shutils/create_genesis_block.sh ${USER}@${ip_host}:~/create_genesis_block.sh
# 	scp -i $SSH_KEY $TOOLS_DIR/shutils/create_miner.sh ${USER}@${ip_host}:~/create_miner.sh
# 	scp -i $SSH_KEY $WORK_DIR/startup/launch_miner_*.sh ${USER}@${ip_host}:~/
	
	### send AWS config files
# 	if [ $AWS == "ON" ]
# 	then
# 		scp -i $SSH_KEY aws_config.txt ${USER}@${ip_host}:~/aws_config
# 		scp -i $SSH_KEY aws_credentials.txt ${USER}@${ip_host}:~/aws_credentials
# 	fi
	
	### send tomcat.service config file
# 	scp -i $SSH_KEY tomcat.service ${USER}@${ip_host}:~/tomcat.service
	
	### send contracts files
# 	scp -r -i $SSH_KEY NovNChain-Web/contracts ${USER}@${ip_host}:~/
	
# 	### send cooptchain-front
# 	scp -i $SSH_KEY nginx.conf ${USER}@${ip_host}:~/
# 	scp -r -i $SSH_KEY NovNChain-Web/cooptchain-front ${USER}@${ip_host}:~/
	
done

for host in $(ls host_cooptchain_admin_${TASK}.ini)
do
  ip_host=$(grep ansible_ssh_host $host | awk '{ print $2}' )
  ip_host=${ip_host#ansible_ssh_host=}

  scp -i $SSH_KEY NovNChain-Web/Cooptthx/target/cooptthx-0.0.1-SNAPSHOT.war ${USER}@${ip_host}:~/

done
cd ..
