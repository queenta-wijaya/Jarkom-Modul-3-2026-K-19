#Tengen
tcpdump -i eth0 -nvv "port 67 or port 68"

#Itadori
dhclient -r eth0 && dhclient -v eth0