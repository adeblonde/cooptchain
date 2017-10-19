#!/bin/bash
#title           :create_genesis_block.sh
#description     :This script will create a genesis.json file.
#author          :MOREL Constance
#date            :20170201
#usage           :bash create_genesis_block.sh <PASSWORD>
#note            :The first account receives 1000wei.
#===============================================================================

PASSWORD=$1

GENESIS_FILE=/Cooptchain/genesis.json
PASSWORD_FILE=password.txt
LIST_ENODES_FILE=/Cooptchain/static-nodes.json

echo "${PASSWORD}" > $PASSWORD_FILE
ACCOUNT_ID=$(geth --password $PASSWORD_FILE account new | awk -F '{' '{print $2}' | awk -F '}' '{print $1}')
rm "${PASSWORD_FILE}"

echo '{
    "nonce": "0x0000000000000005",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "difficulty": "0x01",
    "alloc": {"ACCOUNT_ID": { "balance": "1000" }},
    "coinbase": "0x0000000000000000000000000000000000000000",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "Cooptchain Ethereum Genesis Block",
    "gasLimit": "0xffffffff"
}' > $GENESIS_FILE

sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" $GENESIS_FILE

echo "[]" > "${LIST_ENODES_FILE}"
