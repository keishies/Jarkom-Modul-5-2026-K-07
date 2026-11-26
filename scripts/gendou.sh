#!/bin/sh
iptables -F
iptables -t nat -F
iptables -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 67 --dport 68 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -s 10.67.0.0/21 -j ACCEPT
iptables -A FORWARD -s 10.67.0.0/21 -o eth0 -j ACCEPT
iptables -A FORWARD -s 10.67.0.0/21 -d 10.67.0.0/21 -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.67.0.0/21 -o eth0 -j MASQUERADE