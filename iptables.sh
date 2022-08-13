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

#GLOBAL
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

#LOOPBACK
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#DROP SCAN XMAS/NULL
iptables -A INPUT -m conntrack --ctstate INVALID -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
iptables -A INPUT -m conntrack --ctstate INVALID -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -m conntrack --ctstate INVALID -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -m conntrack --ctstate INVALID -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
 
# DROP BROADCAST PACKETS 
iptables -A INPUT -m pkttype --pkt-type broadcast -j DROP

# ALLOW HTTP/S TO ANYWHERE
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT

# ALLOW SSH TO THE SERVER
iptables -A INPUT -p tcp --dport 2021 -m conntrack --ctstate NEW -j ACCEPT

# ALLOW DNS TRAFFIC TO ANYWHERE
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT


#LOG
iptables -A INPUT -m limit --limit 50/sec -j LOG --log-prefix "INPUT: " --log-level 4
iptables -A OUTPUT -m limit --limit 50/sec -j LOG --log-prefix "OUTPUT: " --log-level 4
iptables -A FORWARD -m limit --limit 50/sec -j LOG --log-prefix "FORWARD: " --log-level 4
