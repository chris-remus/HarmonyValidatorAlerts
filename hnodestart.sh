#!/usr/bin/expect -f

# This script starts node.sh and gives passphrase automatically
# You have to know that is not recommended to store bls key on your validator, especially if is not secure. 
# In this case you could use only the alert part and restart your node manually, once you receive the alerts.

# Edit the passphrase:
set pass "your bls passphrase"


set timeout -1
spawn ./node.sh
expect ".key:"
send "$pass"\r"
expect eof
