#!/bin/sh
# /root/zeruel.sh - Node Zeruel (10.67.4.82)
# Solusi Soal 19: Blokir Armisael (tetangga satu switch) & Listener TCP 9000
echo "nameserver 8.8.8.8" > /etc/resolv.conf

command -v iptables >/dev/null 2>&1 || {
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y --allow-unauthenticated iptables netcat-traditional
}

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -X

# Blokir Armisael (10.67.4.83) agar tidak bisa bicara dengan Zeruel
iptables -A INPUT -s 10.67.4.83 -j DROP
iptables -A OUTPUT -d 10.67.4.83 -j DROP

# Jalankan listener TCP 9000 untuk pengujian Soal 17 & 19
pkill -f "nc.*9000" 2>/dev/null || true
while true; do nc -l -p 9000 >> /root/zeruel_9000.log 2>&1; sleep 0.2; done &
