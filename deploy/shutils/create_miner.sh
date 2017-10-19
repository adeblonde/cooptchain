#!/bin/bash
#title           :create_miner.sh
#description     :This script will set up a miner and add his enode into a file.
#author          :MOREL Constance
#date            :20170201
#usage           :bash create_miner.sh <PASSWORD>
#===============================================================================

PASSWORD=$1

GENESIS_FILE=/Cooptchain/genesis.json
PASSWORD_FILE=password.txt
LIST_ENODES_FILE=/Cooptchain/static-nodes.json
DATADIR=/root/.ethereum

echo "${PASSWORD}" > $PASSWORD_FILE
geth --password $PASSWORD_FILE account new
rm "${PASSWORD_FILE}"

geth init "${GENESIS_FILE}"

IP=$(hostname -i)	
ENODE=$(geth js -- 2>&1 | grep enode | awk -F '//' '{print $2}' | sed "s/\[::\]/${IP}/g")

# Add a new enode at the end of the file.
sed -i -e "s#]#,\n\"enode://${ENODE}\"]#g" "${LIST_ENODES_FILE}"
# Delete the extra comma.
sed -i -e "s#\[,#\[#g" "${LIST_ENODES_FILE}"

ln -sf "${LIST_ENODES_FILE}" "${DATADIR}"
