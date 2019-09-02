#!/bin/bash

# This script checks the change in balance on all 4 shards and alerts via email or SMS if the balance is not growing
# After three loops of alerts per email and/or sms the script exits and restarts the node
# The current setup is configured for both email and sms. If you want to use only email, then the lines with phone number, textbeltkey and
# curl -X POST https://textbelt.com/text --data-urlencode ... need to be commented 
# Also you could use the script only in the alert mode without node restart -> for this comment the lines after "# At exit write log and restart the node"

# Edit these parameters:
# Wallet address
wallet=one address 
# Email address
emailaddress=email address to send the alerts
#Phone number
phonenumber=phone number to send the alerts
# Textbelt key
textbeltkey=textbelt key that you will need to have first
# Delay between checks (E.g. 40s = 40 sec, 2m = 2 min, 1h = 1 hour) It is important to adjust this over time. As the number of joining 
# nodes increases over time, the time between the rewards received will increase as the whole ONE amount will be distributed over more nodes than before.
# If the interval check is too small then false alerts could happen. 
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
  curl -X POST https://textbelt.com/text --data-urlencode phone=''$phonenumber'' --data-urlencode message='ONE rewards missing' -d key=$textbeltkey
  ssmtp $emailaddress < one-alert.txt
  sleep $alert
  emails=$(($emails + 1))

done

# At exit write log and restart the node
date >> hmonitor.log
echo Restart! >> hmonitor.log
pkill node.sh
pkill harmony
sudo ./hnodestart.sh
