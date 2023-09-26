#!/bin/bash

### Take the output of a TX creating Cosmos SDK binary and
### check to see if the TX was successfull, printing details.
### Author: Gaia from FreshSTAKING

### Set the node and binary command
### Enter the values specific to your RPC node, binary to be used and block times
NODE="https://rpc-2.celestia.nodes.guru:443"
CMD="celestia-appd"
WAIT=21 # set this to normal block time + 1 second for safety
### There is no need to change anything from here on

# Check whether the binary is present and in the path
if ! which $CMD > /dev/null; then
    echo "$CMD not found in PATH"
    exit 1
fi

# Read in output from prior command via stdin
input=$(cat)

# Extract relevant fields
CODE=$(echo "$input" | grep "code:" | awk '{print $2}')
TXHASH=$(echo "$input" | grep "txhash:" | awk '{print $2}')
RAW=$(echo "$input" | grep "raw_log:" | sed 's/raw_log: //g')

# Check if transaction was accepted by network
if [ "$CODE" -eq "0" ]
then
  for i in 1 2 3
  do

    echo "Waiting $WAIT seconds for TX to be included in the block (attempt #$i)"

    # Wait for X seconds for the transaction time to be indexed
    sleep $WAIT

    # Query transaction details and extract relevant JSON snippet
    result=$($CMD q tx "$TXHASH" --node "$NODE" -o json 2>&1)

    # Check if JSON snippet was extracted and contains a message type and if yes, print it
    if [[ "$result" =~ "@type" ]]
    then
	CODE=$(jq --argjson j "$result" -n '$j.code')
	if [[ $CODE == "0" ]]
	then
		jq --argjson j "$result" -n '$j.tx.body.messages[]'
		echo "This is the TX ID: $TXHASH"
		exit 0
	else
		echo "TX accepted by the network but failed. It says:"
		jq --argjson j "$result" -n '$j.raw_log'
		echo "This is the TX ID: $TXHASH"
		exit 1
	fi
    fi

  done

  echo "Transaction failed to be indexed after 3 attempts. This is what I got when querying the RPC node: \"$result\""
  exit 1
else
  echo "$CMD did not accept the parameters you used. Please re-issue with the correct parameters after reading its error message, which is either above or here: $RAW"
  exit 1
fi
