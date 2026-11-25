#!/bin/sh
# /root/fuyutsuki.sh - Router Fuyutsuki (Gateway Switch-Terminal)
# Solusi Soal 17: Sihir Hitam di Jalur Paket (DNAT Casper -> Pen-Pen)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Bersihkan dan pasang DNAT
iptables -t nat -F PREROUTING
iptables -t nat -A PREROUTING -p tcp -s 10.67.4.58 -d 10.67.4.82 -j DNAT --to-destination 10.67.3.195
