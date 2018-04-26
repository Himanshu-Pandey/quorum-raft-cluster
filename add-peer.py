from sys import argv
from web3 import Web3, HTTPProvider

w3 = Web3(HTTPProvider(sys.argv[1]))
print w3.admin.addPeer(sys.argv[2])
