#Jichi
#!/bin/sh

# Set Temporary Nameserver untuk download paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Install isc-dhcp-relay
apt-get update && apt-get install -y isc-dhcp-relay

# Konfigurasi /etc/default/isc-dhcp-relay
cat << 'EOF' > /etc/default/isc-dhcp-relay
SERVERS="10.73.4.8"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

# Restart Service DHCP Relay
service isc-dhcp-relay restart || /etc/init.d/isc-dhcp-relay restart

#Itadori
# 1. Set DNS sementara (ke NAT1 / Google)
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 2. Coba update & install ulang
apt-get update && apt-get install -y isc-dhcp-client ifupdown

# 3. Testing
dhclient -v eth0