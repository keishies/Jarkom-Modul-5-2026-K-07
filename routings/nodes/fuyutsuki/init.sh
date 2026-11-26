#!/bin/sh
echo 1 > /proc/sys/net/ipv4/ip_forward
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
ip route replace default via 10.67.4.113
ip route replace 10.67.4.72/29 via 10.67.4.154
ip route replace 10.67.3.192/27 via 10.67.4.150
