#!/sh

$NETWORK="192.168.79.0/24"
nmap -sP $NETWORK | grep -v "Host" | tail -n +3 | tr '\n' ' ' | sed 's|Nmap|\nNmap|g' | grep "MAC Address" | cut -d " " -f5,8