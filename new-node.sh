#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf raft
mkdir raft

echo "[*] Generating enode address"
nohup geth --datadir raft 2>> raft/setup.log &
sleep 3
echo "[\"$(cat raft/setup.log | grep -oEi '(enode.*@)'|head -1)$(hostname -I | cut -f2 -d " "):21000?discport=0&raftport=23000\"]" >> raft/static-nodes.json

echo "[*] Stopping geth"
killall geth

echo "[*] Generating constellation key pair"
cd raft
echo "" | constellation-node --generatekeys=constellation

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Making new account"
mkdir -p qdata/{keystore,geth}
cp raft/static-nodes.json qdata

geth --datadir qdata --password passwords.txt account new 
cp raft/geth/nodekey qdata/geth/nodekey

echo "[*] Initialising geth"
geth --datadir qdata init genesis.json

echo "[*] Starting Constellation node"
ARGS="--url=$(hostname -I | cut -f2 -d " ") --port=9000 --othernodes=[$1] --socket=qdata/tm.ipc  --publickeys=raft/constellation.pub --privatekeys=raft/constellation.key --verbosity=3"
nohup constellation-node $ARGS  2>> qdata/logs/constellation.log &

sudo apt-get install pip
pip install web3

if[[$1]]
then
    echo "[*] installing pip and web3py"
    export LC_ALL="en_US.UTF-8" 
    export LC_CTYPE="en_US.UTF-8" 
    sudo apt-get install python3-pip -y
    pip3 install web3

    echo "[*] calling admin.add peer on http://$1:22000"
    ENODE_ADDR=$(cat raft/static-nodes.json | python -c "import json,sys;obj=json.load(sys.stdin);print obj[0];")
    python3 add-peer.py "http://$1:22000" $ENODE_ADDR
fi

GLOBAL_ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum"
echo "[*] Starting geth"
PRIVATE_CONFIG=tm.conf nohup geth --datadir qdata $GLOBAL_ARGS --rpccorsdomain "*" --rpcport 22000 --port 21000 --raftport 23000 --unlock 0 --password passwords.txt 2>>qdata/logs/geth.log &
