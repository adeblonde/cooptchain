sudo geth 
    --datadir "/home/ethdata2" 
    --networkid 787986 
    --identity "Noel" 
    --port 30303 
    --rpc 
    --rpcaddr 10.1.0.4 
    --rpcport "8545" 
    --rpccorsdomain "*" 
    --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" 
    --rpcapi "db,eth,net,web3,personal" 
    --solc 
    --ws  
    --maxpeers 4 
    --nodiscover 
    --autodag 
    --extradata "NOV" 
    --fakepow
    --unlock "0" 
    --password "pwd.txt" 
    --nat "any" 
    console
