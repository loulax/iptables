#!/bin/bash
iptables="/usr/sbin/iptables"

$iptables -P INPUT ACCEPT
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT

$iptables -t filter -F
$iptables -t filter -X
$iptables -t nat -F
$iptables -t nat -X