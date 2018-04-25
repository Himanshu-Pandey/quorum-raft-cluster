#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf raft
mkdir raft

echo "[*] Generating geth node config"
nohup geth --datadir raft 2>> raft/setup.log &
sleep 3
echo "[\"$(cat raft/setup.log | grep -oEi '(enode.*@)'|head -1)$(hostname -I | cut -f2 -d " "):21000?discport=0&raftport=23000\"]" >> raft/static-nodes.json

# echo "[*] Creating default ethereum account"
# geth --datadir raft --password passwords.txt account new

echo "[*] Stopping geth"
killall geth

echo "[*] Generating constellation key pair"
cd raft
echo "" | constellation-node --generatekeys=constellation

echo "[*] Done"
