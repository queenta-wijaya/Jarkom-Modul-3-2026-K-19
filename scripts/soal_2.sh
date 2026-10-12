#Tengen
#!/bin/sh

# Set nameserver sementara untuk download paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Update repository dan install isc-dhcp-server
apt-get update && apt-get install -y isc-dhcp-server

# Konfigurasi interface isc-dhcp-server
cat << 'EOF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

# Konfigurasi /etc/dhcp/dhcpd.conf
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# 1. Subnet lokal Network 4 (Tanpa Pool Dinamis agar tidak error "No subnet declaration")
subnet 10.73.4.0 netmask 255.255.255.0 {
}

# 2. Scope Network 2 (Divisi A)
subnet 10.73.2.0 netmask 255.255.255.0 {
    range 10.73.2.2 10.73.2.254;
    option routers 10.73.2.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    default-lease-time 3600;
    max-lease-time 7200;
}

# 3. Scope Network 3 (Divisi B)
subnet 10.73.3.0 netmask 255.255.255.0 {
    range 10.73.3.2 10.73.3.254;
    option routers 10.73.3.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    default-lease-time 3600;
    max-lease-time 7200;
}
EOF

# Validasi sintaks konfigurasi
dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Restart dan pastikan service berjalan
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart