### Parse the output of an RPC's peerlist
### into a format ready to paste in persistent peers
### Author: Gaia from FreshSTAKING

### Enter the values specific to your RPC node
RPC_NODE="http://localhost:26657"

peerlist=$(curl -s -H 'Connection: close' $RPC_NODE/net_info)
if [ $? -ne 0 ]; then
  echo "Failed to fetch net_info from $RPC_NODE"
  exit 1
fi

peerlist=$(curl -s -H 'Connection: close' $RPC_NODE/net_info | jq -r '.result.peers[] | "\(.node_info.id), \(.node_info.listen_addr), \(.remote_ip)"')

output=""
total=0

declare -A orgs
declare -A ips

while IFS= read -r line
do
  id=$(echo $line | awk -F', ' '{print $1}')
  ip=$(echo $line | awk -F', ' '{gsub(/tcp:\/\//, "", $2); split($2, a, ":"); print a[1]}')
  remote_ip=$(echo $line | awk -F', ' '{print $3}')
  ips[$ip]=1

  ip=$remote_ip
  ips[$remote_ip]=1

  port=$(echo $line | awk -F', ' '{gsub(/tcp:\/\//, "", $2); split($2, a, ":"); print a[2]}')

  output+="$id@$ip:$port,"

  total=$((total + 1))
done <<< "$peerlist"

# Remove the trailing comma
output=$(echo "$output" | sed 's/,$//')

echo -e "$output" | while IFS= read -r line; do
  if [[ -z "$line" ]]; then continue; fi
  ip=$(echo $line | awk -F'[@:]' '{print $2}')
  echo "$line ${orgs[$ip]}"
done
