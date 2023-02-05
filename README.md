# iptables
iptables is an opensource firewall available on all linux distributions. 
It is easy to setting up rules for any system, you can open/close/forward ports, specify ip address, services etc
He is very powerfull!
You can show it on his official website https://netfilter.org/


# Routing iptables
To enable forward on linux system, you should edit one parameter in 2 distincts files
## For IPv4
/etc/sysctl.conf: net.ipv4.ip_forward=1
/lib/systemd/system/ipv4/ip_forward: 1

## For IPv6
/etc/sysctl.conf: net.ipv6.ip_forward=1
/lib/systemd/system/ipv6/ip_forward: 1 