#Tengen
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart
service isc-dhcp-server stop && service isc-dhcp-server start

#Jichi
service isc-dhcp-relay restart || /etc/init.d/isc-dhcp-relay restart
service isc-dhcp-relay stop && service isc-dhcp-relay start

#Itadori
dhclient -r eth0 && dhclient -v eth0