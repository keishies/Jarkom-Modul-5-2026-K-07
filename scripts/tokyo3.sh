#!/bin/sh
# /root/tokyo3.sh - Tokyo3-Core (10.67.4.106)
# Solusi Soal 15 (Rate limit ping) & Soal 16 (Pencatatan scan Dummy-Plug)
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

# 1. Loopback
iptables -A INPUT -i lo -j ACCEPT

# 2. Soal 16: Pencatatan (SCAN-NERV:) & Penolakan Seketika Scan Port 22, 23, 3306 dari Dummy-Plug
iptables -N SCAN_LOG 2>/dev/null || true
iptables -F SCAN_LOG
iptables -A SCAN_LOG -j LOG --log-prefix "SCAN-NERV: "
iptables -A SCAN_LOG -p tcp -j REJECT --reject-with tcp-reset

for dp in 10.67.4.51 10.67.4.53 10.67.4.54; do
    iptables -A INPUT -p tcp -s "$dp" -m multiport --dports 22,23,3306 -j SCAN_LOG
done

# 3. Soal 15: Limit ping echo-request maksimal 5 per detik, buang kelebihannya
# Urutan ini diletakkan SEBELUM ESTABLISHED,RELATED agar sesi ICMP tidak dianggap ESTABLISHED
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# 4. Stateful Connection untuk meloloskan balasan TCP, DNS, dan balasan ping keluar (echo-reply)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Aktifkan listener port 80 dan port 8080 (Soal 8)
pkill -f "nc.*80" 2>/dev/null || true
pkill -f "nc.*8080" 2>/dev/null || true
while true; do nc.traditional -l -p 80 -c 'echo "Welcome to $(hostname)"'; sleep 0.2; done &
while true; do nc.traditional -l -p 8080 -c 'echo "syifa imutz"'; sleep 0.2; done &
