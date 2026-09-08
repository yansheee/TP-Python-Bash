import subprocess

interfaces = subprocess.getoutput(
    "ip -br addr | awk '$1 != \"lo\" {print $1,$3}'"
)

ports = subprocess.getoutput(
    "ss -tuln | awk 'NR>1 {print $1,$5}'"
)

forwarding = subprocess.getoutput(
    "cat /proc/sys/net/ipv4/ip_forward"
)

firewall = subprocess.getoutput(
    "which ufw > /dev/null && ufw status | head -1 || "
    "which nft > /dev/null && echo 'nftables disponible' || "
    "echo 'Aucun firewall détecté'"
)


network = {
    "interfaces": interfaces,
    "ports": ports,
    "ip_forwarding": forwarding,
    "firewall": firewall
}

print(network)