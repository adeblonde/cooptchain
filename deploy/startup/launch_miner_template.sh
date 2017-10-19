#!/bin/bash

cd /home/ec2-user/go-ethereum/build/bin
eth_dir=/home/ec2-user/go-ethereum/build/bin
mkdir -p /home/ec2-user/ethdata2

PASSWORD="cooptchain"

GENESIS_FILE=/home/ec2-user/ethdata2/genesis.json
PASSWORD_FILE=/home/ec2-user/ethdata2/password.txt
LIST_ENODES_FILE=/home/ec2-user/ethdata2/static-nodes.json

### copy geth to path
sudo cp ${eth_dir}/geth /usr/bin

echo "${PASSWORD}" > $PASSWORD_FILE
ACCOUNT_ID=$(geth --password $PASSWORD_FILE account new | awk -F '{' '{print $2}' | awk -F '}' '{print $1}')
# rm "${PASSWORD_FILE}"

echo '{
    "nonce": "0x0000000000000005",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "difficulty": "0x01",
    "alloc": {"ACCOUNT_ID": { "balance": "1000" }},
    "coinbase": "0x0000000000000000000000000000000000000000",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "CooptChain Ethereum Genesis Block",
    "gasLimit": "0xffffffff"
}' > $GENESIS_FILE

sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" $GENESIS_FILE

echo "[]" > "${LIST_ENODES_FILE}"

geth init $GENESIS_FILE

geth \
    --datadir "/home/ec2-user/ethdata2" \
    --networkid 787986 \
    --identity "IDENTITY" \
    --port 30303 \
    --rpc \
    --rpcport "8545" \
    --rpccorsdomain "*" \
    --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" \
    --rpcapi "db,eth,net,web3,personal" \
    --solc \
    --ws \
    --maxpeers 4 \
    --nodiscover \
    --autodag \
    --extradata "NOV" \
    --fakepow \
    --etherbase="${ACCOUNT_ID}" \
    --password "${PASSWORD_FILE}" \
    --nat "any" \
    --mine
