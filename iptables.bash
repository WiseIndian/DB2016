sudo iptables -A INPUT -p tcp -i eth0 --dport ssh -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth0 --dport 9000 -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth0 --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -i lo -j ACCEPT
sudo iptables -P INPUT DROP

##the following is to be sure that when we test a new iptable policy we can recover
#echo "$(date -d "+5 minutes" +'%M %H') * * * bash /home/simonlbc/DB2016/resetIptables.bash" |
#sudo crontab -
