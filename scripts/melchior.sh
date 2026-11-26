#!/bin/sh
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt -o Acquire::Check-Valid-Until=false update
apt install -y --allow-unauthenticated iptables netcat-traditional
pkill -f "nc -l" 2>/dev/null
while true; do nc -l -p 5000 >> /root/melchior.log; done &