set -u
set -e

echo "[*] Starting Constellation node"
ARGS="--url=$(hostname -I | cut -f1 -d " ") --port=9000 --othernodes=[$1] --socket=qdata/tm.ipc  --publickeys=[raft/constellation.pub]  --privatekeys=raft/constellation.key  storage=qdata/constellation --verbosity=3"
nohup constellation-node $ARGS  2>> qdata/logs/constellation.log &
