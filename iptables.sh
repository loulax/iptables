#!/bin/bash

#CLEAR IPTABLES RULES
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

#SET DEFAULT POLICY
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# ALLOW WEB REQUEST FROM LAN
iptables -A INPUT -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# ALLOW WEB ACCESS FROM WAN
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW SSH FROM WAN
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW NAT MASQUERADE
iptables -A POSTROUTING -t nat -o <interface> -j MASQUERADE

# ALLOW NAT PREROUTING 2345
iptables -A PREROUTING -t nat -p tcp --dport 2345 -d <public_ip> -j DNAT  --to-destination <lan_ip>:2345 

#LOG
iptables -A INPUT -m limit --limit 50/sec -j LOG --log-prefix "INPUT: " --log-level 4
iptables -A OUTPUT -m limit --limit 50/sec -j LOG --log-prefix "OUTPUT: " --log-level 4
iptables -A FORWARD -m limit --limit 50/sec -j LOG --log-prefix "FORWARD: " --log-level 4
