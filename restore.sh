#!/bin/bash

/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT

/sbin/iptables -t filter -F
/sbin/iptables -t filter -X
/sbin/iptables -t nat -F
/sbin/iptables -t nat -X

