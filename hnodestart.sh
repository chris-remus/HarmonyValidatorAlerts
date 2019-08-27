#!/usr/bin/expect -f

# This script starts node.sh and gives passphrase automatically

# Edit the passphrase:
set pass "your bls passphrase"


set timeout -1
spawn ./node.sh
expect ".key:"
send "$pass"\r"
expect eof
