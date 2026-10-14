#Tengen
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# ==========================================
# KELAS NETWORK 2 (DIVISI A) - SOAL 4
# ==========================================
# Dev Team: itadori & fushiguro
class "dev-team" {
    match if hardware = 1:02:42:d6:17:eb:00 or
             hardware = 1:02:42:58:7f:b4:00;
}

# Support Team: zenin & okkotsu
class "support-team" {
    match if hardware = 1:02:42:0c:74:7a:00 or
             hardware = 1:02:42:80:05:e5:00;
}

# ==========================================
# KELAS NETWORK 3 (DIVISI B) - SOAL 5
# ==========================================
# Short Lease Clients (30m / 1800s): ino & kusakabe
class "short-lease-clients" {
    match if hardware = 1:02:42:87:5f:a1:00 or
             hardware = 1:02:42:61:7e:7f:00;
}

# Long Lease Clients (12j / 43200s): miwa
class "long-lease-clients" {
    match if hardware = 1:02:42:ac:34:54:00;
}

# ==========================================
# STATIC LEASE VIP (SOAL 6) - KUGISAKI
# ==========================================
host kugisaki {
    hardware ethernet 02:42:c4:b9:32:00;
    fixed-address 10.73.3.99;
}

# ==========================================
# SUBNET DEFINITIONS & OPTIONS
# ==========================================
subnet 10.73.4.0 netmask 255.255.255.0 {
}

# Subnet Network 2 (Divisi A)
subnet 10.73.2.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.73.2.255;
    option routers 10.73.2.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    option domain-search "jujutsu.com";

    pool {
        allow members of "dev-team";
        range 10.73.2.10 10.73.2.35;
    }

    pool {
        allow members of "support-team";
        range 10.73.2.70 10.73.2.95;
    }
}

# Subnet Network 3 (Divisi B)
subnet 10.73.3.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.73.3.255;
    option routers 10.73.3.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    option domain-search "jujutsu.com";

    pool {
        allow members of "short-lease-clients";
        range 10.73.3.10 10.73.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    pool {
        allow members of "long-lease-clients";
        range 10.73.3.100 10.73.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
EOF

# Validasi sintaks dan restart service DHCP
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart

#Kugisaki
udhcpc -i eth0