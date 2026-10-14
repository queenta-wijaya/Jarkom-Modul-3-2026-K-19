#Tengen
tcpdump -i eth0 -nvv "port 67 or port 68"

#Itadori
udhcpc -i eth0 -n -q