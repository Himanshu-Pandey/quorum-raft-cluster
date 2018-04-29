var Web3 = require('web3quorum');
var web3 = new Web3(new Web3.providers.HttpProvider(process.argv[2]));
var res = web3.raft.addPeer(process.argv[3]);

console.log(res);
return res;
