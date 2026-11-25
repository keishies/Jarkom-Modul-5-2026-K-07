#!/bin/sh
# /root/balthasar.sh - Magi-Balthasar (10.67.4.59)
# Solusi Soal 13: Brankas Balthasar
echo "nameserver 8.8.8.8" > /etc/resolv.conf

command -v iptables >/dev/null 2>&1 || {
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y --allow-unauthenticated iptables netcat-traditional
}

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -X

# 1. Loopback & Stateful Connection
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2. Whitelist: Hanya Casper dan semua Pilot yang boleh akses port 5000 & 5001
# Casper (10.67.4.58)
iptables -A INPUT -p tcp -s 10.67.4.58 -m multiport --dports 5000,5001 -j ACCEPT
# Pilot Cage (Unit-01: .66, Unit-02: .67, Unit-00: .68)
iptables -A INPUT -p tcp -s 10.67.4.66 -m multiport --dports 5000,5001 -j ACCEPT
iptables -A INPUT -p tcp -s 10.67.4.67 -m multiport --dports 5000,5001 -j ACCEPT
iptables -A INPUT -p tcp -s 10.67.4.68 -m multiport --dports 5000,5001 -j ACCEPT
# Pilot Bunker (Sachiel: 10.67.3.130)
iptables -A INPUT -p tcp -s 10.67.3.130 -m multiport --dports 5000,5001 -j ACCEPT

# 3. Reject seketika (TCP RST) semua node lain ke port 5000 & 5001
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -j REJECT --reject-with tcp-reset

# Lalu lintas lain tetap ACCEPT (Balthasar tetap bisa ping 8.8.8.8 dan menerima reply)
iptables -P INPUT ACCEPT

# Aktifkan listener TCP 5000 & 5001
pkill -f "nc.*5000" 2>/dev/null || true
pkill -f "nc.*5001" 2>/dev/null || true
while true; do nc -l -p 5000 >> /root/balthasar_5000.log 2>&1; sleep 0.2; done &
while true; do nc -l -p 5001 >> /root/balthasar_5001.log 2>&1; sleep 0.2; done &
