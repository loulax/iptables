#!/bin/bash

#CLEAR IPTABLES RULES
/usr/sbin/iptables -F
/usr/sbin/iptables -X
/usr/sbin/iptables -t nat -F
/usr/sbin/iptables -t nat -X

#SET DEFAULT POLICY
/usr/sbin/iptables -P INPUT DROP
/usr/sbin/iptables -P OUTPUT DROP
/usr/sbin/iptables -P FORWARD DROP

#SET CUSTOM CHAIN
iptables -N fw_in_allowed
iptablkes -N fw_out_allowed

#REDIRECT DEFAULT CHAIN TO NEW
iptables -A INPUT -j fw_in_allowed
iptables -A OUPUT -j fw_out_allowed

# ALLOW WEB REQUEST FROM LAN
/usr/sbin/iptables -A fw_in_allowed -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
/usr/sbin/iptables -A fw_in_allowed -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# ALLOW WEB ACCESS FROM WAN
/usr/sbin/iptables -A fw_in_allowed -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
/usr/sbin/iptables -A fw_out_allowed -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW DNS REQUEST FROM LAN
/usr/sbin/iptables -A fw_in_allowed -p udp --dport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
/usr/sbin/iptables -A fw_out_allowed -p udp --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# ALLOW SSH FROM WAN
/usr/sbin/iptables -A fw_in_allowed -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
/usr/sbin/iptables -A fw_out_allowed -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW NAT MASQUERADE
/usr/sbin/iptables -A POSTROUTING -t nat -o <interface> -j MASQUERADE

# ALLOW NAT PREROUTING 2345
/usr/sbin/iptables -A PREROUTING -t nat -p tcp --dport 2345 -d <public_ip> -j DNAT  --to-destination <lan_ip>:2345 

#LOG
/usr/sbin/iptables -A INPUT -m limit --limit 50/sec -j LOG --log-prefix "INPUT DROP: " --log-level 4
/usr/sbin/iptables -A OUTPUT -m limit --limit 50/sec -j LOG --log-prefix "OUTPUT DROP: " --log-level 4
/usr/sbin/iptables -A FORWARD -m limit --limit 50/sec -j LOG --log-prefix "FORWARD DROP: " --log-level 4
