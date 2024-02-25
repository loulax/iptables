#!/bin/bash

iptables="/usr/sbin/iptables"

#CLEAR IPTABLES RULES
$iptables -F
$iptables -X
$iptables -t nat -F
$iptables -t nat -X

#SET DEFAULT POLICY
$iptables -P INPUT DROP
$iptables -P OUTPUT DROP
$iptables -P FORWARD DROP

#SET CUSTOM CHAIN
$iptables -N net_in
$iptables -N net_out
$iptables -N net_fw
$iptables -t nat -N post_route
$iptables -t nat -N pre_route

#REDIRECT DEFAULT CHAIN TO NEW
$iptables -A INPUT -j net_in
$iptables -A OUTPUT -j net_out
$iptables -A FORWARD -j net_fw
$iptables -t nat -A PREROUTING -j pre_route
$iptables -t nat -A POSTROUTING -j post_route

# ALLOW WEB REQUEST FROM LAN
$iptables -A net_in -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
$iptables -A net_in -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# ALLOW DNS REQUEST FROM LAN
$iptables -A net_in -p udp --dport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
$iptables -A net_out -p udp --sport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# ALLOW WEB ACCESS FROM WAN
$iptables -A net_in -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
$iptables -A net_out -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW SSH FROM WAN
$iptables -A net_in -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
$iptables -A net_out -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOW NAT MASQUERADE
#$iptables -A POSTROUTING -t nat -o <interface> -j MASQUERADE

# ALLOW NAT PREROUTING 2345
#$iptables -A PREROUTING -t nat -p tcp --dport 2345 -d <public_ip> -j DNAT  --to-destination <lan_ip>:2345 

#LOG
$iptables -A INPUT -m limit --limit 50/sec -j LOG --log-prefix "INPUT DROP: " --log-level 4
$iptables -A OUTPUT -m limit --limit 50/sec -j LOG --log-prefix "OUTPUT DROP: " --log-level 4
$iptables -A FORWARD -m limit --limit 50/sec -j LOG --log-prefix "FORWARD DROP: " --log-level 4
