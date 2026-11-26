#!/bin/sh
echo 1 > /proc/sys/net/ipv4/ip_forward
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
ip route replace default via 10.67.4.109
ip route replace 10.67.4.0/27 via 10.67.4.138
ip route replace 10.67.0.0/23 via 10.67.4.142
ip route replace 10.67.4.32/28 via 10.67.4.146
