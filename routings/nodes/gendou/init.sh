#!/bin/sh
echo 1 > /proc/sys/net/ipv4/ip_forward
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

for n in 10.67.0.0/23 10.67.3.0/25 10.67.4.0/27 10.67.4.32/28 10.67.4.136/30 10.67.4.140/29; do ip route replace $n via 10.67.4.110; done
for n in 10.67.2.0/24 10.67.3.224/27 10.67.4.168/30; do ip route replace $n via 10.67.4.134; done
for n in 10.67.3.128/26 10.67.4.48/29 10.67.4.96/30 10.67.4.160/29; do ip route replace $n via 10.67.4.130; done
ip route replace 10.67.4.100/30 via 10.67.4.126
ip route replace 10.67.4.64/29 via 10.67.4.122
for n in 10.67.4.80/28 10.67.4.156/30; do ip route replace $n via 10.67.4.118; done
for n in 10.67.3.192/27 10.67.4.56/29 10.67.4.72/29 10.67.4.148/29; do ip route replace $n via 10.67.4.114; done
