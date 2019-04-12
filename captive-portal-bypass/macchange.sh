#!/sh

IFACE=$1
MAC=$2

ip link set $IFACE down
ip link set dev $IFACE address $MAC
ip link set $IFACE up
ip addr flush dev $IFACE

echo "New MAC: $MAC"
echo

ifconfig $IFACE