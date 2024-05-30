#!/bin/bash

os=$(lsb_release -d |awk '{print $2}')
chmod +x *.sh
cp *.sh /etc/init.d
cp firewall.service /lib/systemd/system/

if [[ $os == "Debian" ]] || [[ $os == "Ubuntu" ]]; then

    apt -y install iptables

elif [[ $os == "Fedora" ]]; then

    dnf install iptables-services

elif [[ $os == "Arch" ]]; then

    pacman -Sy iptables
fi

systemctl daemon-reload
systemctl start firewall
iptables -L
echo "Don't forget to enable the service then when the rules are correctly setup"