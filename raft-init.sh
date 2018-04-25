#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node"
mkdir -p qdata/{keystore,geth}
cp raft/static-nodes.json qdata

geth --datadir qdata --password passwords.txt account new 
cp raft/geth/nodekey qdata/geth/nodekey

geth --datadir qdata init genesis.json
