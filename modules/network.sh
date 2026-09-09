#!/bin/bash

interfaces=$(ip -br addr | awk '$1 != "lo" {print $1,$3}')
ports=$(ss -tuln | awk 'NR>1 {print $1,$5}')
forwarding=$(cat /proc/sys/net/ipv4/ip_forward)

firewall=$(
    which ufw > /dev/null && ufw status | head -1 ||
    which nft > /dev/null && echo "nftables disponible" ||
    echo "Aucun firewall détecté"
)

declare -A network

network["interfaces"]="$interfaces"
network["ports"]="$ports"
network["ip_forwarding"]="$forwarding"
network["firewall"]="$firewall"

echo "${network[@]}"