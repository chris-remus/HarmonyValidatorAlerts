#!/bin/bash

# This script checks the change in balance and alerts via email or SMS if balance not growing
# After three loops of alerts the script exits and restarts the node

# Edit these parameters:
# Wallet address
wallet=one address 
# Email address
emailaddress=email address to send the alerts
#Phone number
phonenumber=phone number to send the alerts
# Textbelt key
textbeltkey=textbelt key that you need to get
# Delay between checks (E.g. 40s = 40 sec, 2m = 2 min, 1h = 1 hour)
check=50s
# Delay before re-sending the alert
alert=2m
# Preset the email counter
emails=0
# Main loop
while [[ $emails -le 2 ]]
do
  # Initial checking of balances
  # Check starting balances (fractions of ONEs, four first digits)
  ./wallet.sh balances --address $wallet > balances
  bal0=`cat balances |grep -i "shard 0"  |cut -f 2 -d "." |cut -c 1-4`
  bal0=`expr $bal0 + 0`
  bal1=`cat balances |grep -i "shard 1"  |cut -f 2 -d "." |cut -c 1-4`
  bal1=`expr $bal1 + 0`
  bal2=`cat balances |grep -i "shard 2"  |cut -f 2 -d "." |cut -c 1-4`
  bal2=`expr $bal2 + 0`
  bal3=`cat balances |grep -i "shard 3"  |cut -f 2 -d "." |cut -c 1-4`
  bal3=`expr $bal3 + 0`
  cents1=$(($bal0 + $bal1 + $bal2 + $bal3))

  # Check balance fractions again after the delay 
  sleep $check
  ./wallet.sh balances --address $wallet > balances
  bal0=`cat balances |grep -i "shard 0"  |cut -f 2 -d "." |cut -c 1-4`
  bal0=`expr $bal0 + 0`
  bal1=`cat balances |grep -i "shard 1"  |cut -f 2 -d "." |cut -c 1-4`
  bal1=`expr $bal1 + 0`
  bal2=`cat balances |grep -i "shard 2"  |cut -f 2 -d "." |cut -c 1-4`
  bal2=`expr $bal2 + 0`
  bal3=`cat balances |grep -i "shard 3"  |cut -f 2 -d "." |cut -c 1-4`
  bal3=`expr $bal3 + 0`
  cents2=$(($bal0 + $bal1 + $bal2 + $bal3))

  while [[ $cents1 != $cents2 ]]
  do
      # Check starting balances (fractions of ONEs, four fist digits)
    ./wallet.sh balances --address $wallet > balances
    bal0=`cat balances |grep -i "shard 0"  |cut -f 2 -d "." |cut -c 1-4`
    bal0=`expr $bal0 + 0`
    bal1=`cat balances |grep -i "shard 1"  |cut -f 2 -d "." |cut -c 1-4`
    bal1=`expr $bal1 + 0`
    bal2=`cat balances |grep -i "shard 2"  |cut -f 2 -d "." |cut -c 1-4`
    bal2=`expr $bal2 + 0`
    bal3=`cat balances |grep -i "shard 3"  |cut -f 2 -d "." |cut -c 1-4`
    bal3=`expr $bal3 + 0`
    cents1=$(($bal0 + $bal1 + $bal2 + $bal3))

       # Check balance fractions again after the delay
    sleep $check
    ./wallet.sh balances --address $wallet > balances
    bal0=`cat balances |grep -i "shard 0"  |cut -f 2 -d "." |cut -c 1-4`
    bal0=`expr $bal0 + 0`
    bal1=`cat balances |grep -i "shard 1"  |cut -f 2 -d "." |cut -c 1-4`
    bal1=`expr $bal1 + 0`
    bal2=`cat balances |grep -i "shard 2"  |cut -f 2 -d "." |cut -c 1-4`
    bal2=`expr $bal2 + 0`
    bal3=`cat balances |grep -i "shard 3"  |cut -f 2 -d "." |cut -c 1-4`
    bal3=`expr $bal3 + 0`
    cents2=$(($bal0 + $bal1 + $bal2 + $bal3))
    date >> surv.log
    echo All fine! >> surv.log

  done

   # Exit inner loop if balance not changed
  date >> surv.log
  echo No rewards! >> surv.log
  # curl -X POST https://textbelt.com/text --data-urlencode phone=''$phonenumber'' --data-urlencode message='ONE rewards missing' -d key=$textbeltkey
  ssmtp $emailaddress < one-alert.txt
  sleep $alert
  emails=$(($emails + 1))

done

# At exit write log and restart the node
#date >> surv.log
#echo Restart! >> surv.log
#pkill node.sh
#pkill harmony
#sudo ./startone.sh
