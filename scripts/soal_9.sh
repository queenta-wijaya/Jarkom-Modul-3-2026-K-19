#Jichi (dimatikan)
service isc-dhcp-relay stop || /etc/init.d/isc-dhcp-relay stop

#Jichi (dinyalakan)
service isc-dhcp-relay start || /etc/init.d/isc-dhcp-relay start

#Itadori
dhclient -r eth0 && dhclient -v eth0