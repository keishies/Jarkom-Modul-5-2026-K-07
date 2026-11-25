#!/bin/sh
# /root/penpen.sh - Pen-Pen (10.67.3.195)
# Solusi Soal 14: Jam Kunjungan Sang Pinguin

# Variabel Jadwal Waktu UTC (WIB = UTC + 7)
# Default Pilot: 08.00-16.00 WIB (Senin-Jumat) -> 01:00-09:00 UTC
# Default Staf:  17.00-23.00 WIB (Setiap hari)  -> 10:00-16:00 UTC
PILOT_START="${PILOT_START:-01:00}"
PILOT_STOP="${PILOT_STOP:-09:00}"
PILOT_DAYS="${PILOT_DAYS:-Mon,Tue,Wed,Thu,Fri}"
STAF_START="${STAF_START:-10:00}"
STAF_STOP="${STAF_STOP:-16:00}"

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

# 2. Chain Khusus Akses Pen-Pen (Ping & TCP 80)
iptables -N PENPEN_ACCESS
iptables -A INPUT -p icmp --icmp-type echo-request -j PENPEN_ACCESS
iptables -A INPUT -p tcp --dport 80 -j PENPEN_ACCESS

# Terduga Dummy System: SELALU DITOLAK (Entry-Plug, Dummy-Plug, Spy)
for dummy_ip in 10.67.4.50 10.67.4.51 10.67.4.52 10.67.4.53 10.67.4.54 10.67.4.102; do
    iptables -A PENPEN_ACCESS -s "$dummy_ip" -j REJECT
done

# Pilot: Sesuai Jadwal Pilot
for pilot_ip in 10.67.4.66 10.67.4.67 10.67.4.68 10.67.3.130; do
    iptables -A PENPEN_ACCESS -s "$pilot_ip" -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
    iptables -A PENPEN_ACCESS -s "$pilot_ip" -j REJECT
done

# Staf Geofront: Sesuai Jadwal Staf
for staf_ip in 10.67.4.74 10.67.4.75; do
    iptables -A PENPEN_ACCESS -s "$staf_ip" -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
    iptables -A PENPEN_ACCESS -s "$staf_ip" -j REJECT
done

# Lainnya: Bebas tanpa batasan
iptables -A PENPEN_ACCESS -j ACCEPT

# Jalankan listener port 80 dan port 9000 (untuk Soal 17)
pkill -f "nc.*80" 2>/dev/null || true
pkill -f "nc.*9000" 2>/dev/null || true
while true; do nc.traditional -l -p 80 -c 'echo "Welcome to $(hostname)"'; sleep 0.2; done &
while true; do nc -l -p 9000 >> /root/penpen_9000.log 2>&1; sleep 0.2; done &
