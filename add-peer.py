from sys import argv
from web3 import Web3, HTTPProvider

w3 = Web3(HTTPProvider(argv[1]))
print(w3.admin.addPeer(argv[2]))
