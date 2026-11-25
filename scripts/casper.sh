#!/bin/sh
# /root/casper.sh - Magi-Casper (10.67.4.58)
# Solusi Soal 11 & Perbaikan Soal 12
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Pasang paket jika belum ada
command -v iptables >/dev/null 2>&1 || {
    apt -o Acquire::Check-Valid-Until=false update
    apt install -y --allow-unauthenticated iptables netcat-traditional
}

# Reset dan terapkan aturan hardening
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -X

# 1. Izinkan Loopback
iptables -A INPUT -i lo -j ACCEPT

# 2. Stateful conntrack (Perbaikan Soal 12: mengizinkan balasan paket keluar seperti ping & apt-get)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. Izinkan Service Port TCP 5000 (Magi-Casper)
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# 4. Blokir ICMP echo-request (Soal 11: Tidak ada yang boleh mem-ping Casper)
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# 5. Policy INPUT DROP (Sesuai Soal 12)
iptables -P INPUT DROP

# 6. Pastikan OUTPUT bersih (Menghapus blokir UDP 53 DNS dari sabotase Soal 12)
iptables -F OUTPUT
iptables -P OUTPUT ACCEPT

# 7. Aktifkan listener TCP 5000
pkill -f "nc.*5000" 2>/dev/null || true
while true; do nc -l -p 5000 >> /root/casper_5000.log 2>&1; sleep 0.2; done &
