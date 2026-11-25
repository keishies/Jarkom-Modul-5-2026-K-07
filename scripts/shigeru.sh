#!/bin/sh
# /root/shigeru.sh - Router Shigeru (Gateway Switch-Monolith)
# Solusi Soal 18 (Gerbang Monolith & Radar) & Soal 19 (Isolasi Armisael)
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -P FORWARD ACCEPT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -X

# 1. Soal 19: Isolasi Armisael (10.67.4.83) pada router Shigeru
iptables -A INPUT -s 10.67.4.83 -j DROP
iptables -A INPUT -d 10.67.4.83 -j DROP
iptables -A FORWARD -s 10.67.4.83 -j DROP
iptables -A FORWARD -d 10.67.4.83 -j DROP

# 2. Soal 18: Stateful connection (node dalam zona boleh konek ke mana saja dan balasannya sampai)
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. Soal 18: Pengecualian ping dari Switch-Terminal (10.67.4.56/29) masuk via eth0
iptables -A FORWARD -i eth0 -s 10.67.4.56/29 -p icmp --icmp-type echo-request -j ACCEPT

# 4. Soal 18: Tolak semua koneksi baru yang datang dari sisi menghadap Gendo (eth0)
iptables -A FORWARD -i eth0 -j DROP
