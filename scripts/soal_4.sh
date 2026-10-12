#Tengen
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# 1. Deklarasi Class Berdasarkan MAC Address Fisik Node
# Dev Team: itadori & fushiguro
class "dev-team" {
    match if hardware = 1:02:42:c0:a6:93:00 or
             hardware = 1:02:42:f9:82:71:00;
}

# Support Team: zenin & okkotsu
class "support-team" {
    match if hardware = 1:02:42:80:8b:ed:00 or
             hardware = 1:02:42:d3:9d:2d:00;
}

# 2. Subnet Lokal Network 4 (Data Center)
subnet 10.73.4.0 netmask 255.255.255.0 {
}

# 3. Subnet Network 2 (Divisi A)
subnet 10.73.2.0 netmask 255.255.255.0 {
    option routers 10.73.2.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;

    # Pool 1: Dev Team (itadori & fushiguro) -> 10.73.2.10 s/d 10.73.2.35
    pool {
        allow members of "dev-team";
        range 10.73.2.10 10.73.2.35;
    }

    # Pool 2: Support Team (zenin & okkotsu) -> 10.73.2.70 s/d 10.73.2.95
    pool {
        allow members of "support-team";
        range 10.73.2.70 10.73.2.95;
    }
}

# 4. Subnet Network 3 (Divisi B)
subnet 10.73.3.0 netmask 255.255.255.0 {
    range 10.73.3.2 10.73.3.254;
    option routers 10.73.3.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
}
EOF

# Validasi Syntax & Restart Service
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart

#Itadori dan Fushiguro
dhclient -r eth0 && dhclient -v eth0

#Zenin dan Okkotsu
dhclient -r eth0 && dhclient -v eth0

#Jangan lupa di Itadori, Fushiguro, Zenin, Okkotsu
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y isc-dhcp-client ifupdown
