#Tengen
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# ==========================================
# KELAS NETWORK 2 (DIVISI A) - SOAL 4 (MAC TERBARU)
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
class "short-lease-clients" {
    match if hardware = 1:02:42:53:99:4e:00 or
             hardware = 1:02:42:82:1f:d5:00;
}

class "long-lease-clients" {
    match if hardware = 1:02:42:18:10:54:00;
}

# ==========================================
# STATIC LEASE (RESERVASI IP VIP) - SOAL 6
# ==========================================
host kugisaki {
    hardware ethernet f2:dd:ec:51:c9:cb;
    fixed-address 10.73.3.99;
}

# ==========================================
# SUBNET DEFINITIONS & OPTIONS - SOAL 7
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

    # Pool 1: Dev Team (10.73.2.10 - 10.73.2.35)
    pool {
        allow members of "dev-team";
        range 10.73.2.10 10.73.2.35;
    }

    # Pool 2: Support Team (10.73.2.70 - 10.73.2.95)
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

    # Pool Short Lease (1800s / 30m)
    pool {
        allow members of "short-lease-clients";
        range 10.73.3.10 10.73.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Pool Long Lease (43200s / 12j)
    pool {
        allow members of "long-lease-clients";
        range 10.73.3.100 10.73.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
EOF

# Validasi sintaks dan restart service
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart

#Itadori dan Fushiguro
udhcpc -i eth0

#Zenin dan Okkotsu
udhcpc -i eth0

