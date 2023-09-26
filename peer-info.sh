### Parse the output of an RPC's peerlist
### into a readable format including information
### whether the peer is in/outbound
### and the likely city the peer is in
### Author: Gaia from FreshSTAKING

### Enter the values specific to your RPC node
RPC_NODE="http://localhost:26657"

# If would like to see IP information for each peer,
# get a free API key from https://ipinfo.io
API_TOKEN="b160f016eb7662"
# This API token is being provided for scoring purposes
# and will be invalidated after scoring is done

### No need to touch from here down

peerlist=$(curl -s -H 'Connection: close' $RPC_NODE/net_info)
if [ $? -ne 0 ]; then
  echo "Failed to fetch net_info from $RPC_NODE"
  exit 1
fi

peerlist=$(curl -s -H 'Connection: close' $RPC_NODE/net_info | jq -r '.result.peers[] | "\(.node_info.id), \(.node_info.listen_addr), \(.remote_ip), \(.is_outbound)"')

sep="\n"

declare -A orgs
declare -A ips

output=""
total=0
outbound=0

while IFS= read -r line
do
  id=$(echo $line | awk -F', ' '{print $1}')
  ip=$(echo $line | awk -F', ' '{gsub(/tcp:\/\//, "", $2); split($2, a, ":"); print a[1]}')
  remote_ip=$(echo $line | awk -F', ' '{print $3}')
  is_outbound=$(echo $line | awk -F', ' '{print $4}' | tr -d '[:space:]')
  ips[$ip]=1

  ip=$remote_ip
  ips[$remote_ip]=1

  port=$(echo $line | awk -F', ' '{gsub(/tcp:\/\//, "", $2); split($2, a, ":"); print a[2]}')

  if [[ "$is_outbound" == "true" ]]; then
    outbound=$((outbound + 1))
    output+="$id@$ip:$port, outbound, $sep"
  else
    output+="$id@$ip:$port, inbound, $sep"
  fi
  total=$((total + 1))
done <<< "$peerlist"

ip_list=$(printf ', "%s/city"' "${!ips[@]}")
ip_list=${ip_list:1}
orgs_json=$(curl -s -XPOST --data "[$ip_list]" "https://ipinfo.io/batch?token=$API_TOKEN")
for ip in "${!ips[@]}"; do
  org=$(echo "$orgs_json" | jq -r ".\"$ip/city\"")
  if [ "$org" == "null" ]; then
    orgs[$ip]="Not Available"
  else
    orgs[$ip]=$org
  fi
done

echo -e "$output" | while IFS= read -r line; do
  if [[ -z "$line" ]]; then continue; fi
  ip=$(echo $line | awk -F'[@:]' '{print $2}')
  echo "$line ${orgs[$ip]}"
done

echo -e "\n============== This node has $total peers, out of which $outbound are outbound."
