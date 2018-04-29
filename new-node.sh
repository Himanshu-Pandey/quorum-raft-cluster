set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf raft
mkdir raft

echo "[*] Generating geth node config"
nohup geth --datadir raft 2>> raft/setup.log &
sleep 3
echo "[\"$(cat raft/setup.log | grep -oEi '(enode.*@)'|head -1)$(hostname -I | cut -f2 -d " "):21000?discport=0&raftport=23000\"]" >> raft/static-nodes.json

echo "[*] Stopping geth"
killall geth

echo "[*] Generating constellation key pair"
echo "" | constellation-node --generatekeys=raft/constellation

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node"
mkdir -p qdata/{keystore,geth}
cp raft/static-nodes.json qdata

geth --datadir qdata --password passwords.txt account new
cp raft/geth/nodekey qdata/geth/nodekey
geth --datadir qdata init genesis.json

echo "[*] Starting Constellation node"

if [[ $1 ]]
then
    ARGS="--url=http://$(hostname -I | cut -f2 -d " "):9000/ --port=9000 --othernodes=[$1:9000/] --socket=qdata/tm.ipc  --publickeys=raft/constellation.pub --privatekeys=raft/constellation.key --verbosity=3"
else
    ARGS="--url=http://$(hostname -I | cut -f2 -d " "):9000/ --port=9000 --socket=qdata/tm.ipc  --publickeys=raft/constellation.pub --privatekeys=raft/constellation.key --verbosity=3"
fi

nohup constellation-node $ARGS  2>> qdata/logs/constellation.log &
GLOBAL_ARGS="--raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft"

if [[ $1 ]]
then
    echo "[*] Adding a new peer at $1:22000"
    npm install web3quorum 
    ENODE_ADDR=$(cat raft/static-nodes.json | python -c "import json,sys;obj=json.load(sys.stdin);print obj[0];")
    RAFT_ID=$(nodejs add-peer.js "$1:22000" $ENODE_ADDR)

    echo "[*] Starting geth node"
    nohup geth --datadir qdata $GLOBAL_ARGS --rpccorsdomain "*" --raftjoinexisting $RAFT_ID --rpcport 22000 --port 21000 --raftport 23000 --unlock 0 --password passwords.txt 2>>qdata/logs/geth.log &
else
    echo "[*] Starting geth node"
    nohup geth --datadir qdata $GLOBAL_ARGS --rpccorsdomain "*" --rpcport 22000 --port 21000 --raftport 23000 --unlock 0 --password passwords.txt 2>>qdata/logs/geth.log &
fi
