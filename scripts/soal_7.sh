#Tengen
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# ==========================================
# KELAS NETWORK 2 (DIVISI A)
# ==========================================
class "dev-team" {
    match if hardware = 1:02:42:d6:17:eb:00 or
             hardware = 1:02:42:58:7f:b4:00;
}

class "support-team" {
    match if hardware = 1:02:42:0c:74:7a:00 or
             hardware = 1:02:42:80:05:e5:00;
}

# ==========================================
# KELAS NETWORK 3 (DIVISI B)
# ==========================================
class "short-lease-clients" {
    match if hardware = 1:02:42:87:5f:a1:00 or
             hardware = 1:02:42:61:7e:7f:00;
}

class "long-lease-clients" {
    match if hardware = 1:02:42:ac:34:54:00;
}

# ==========================================
# STATIC LEASE (KUGISAKI)
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

subnet 10.73.2.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.73.2.255;
    option routers 10.73.2.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    option domain-name "jujutsu.com";
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

subnet 10.73.3.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.73.3.255;
    option routers 10.73.3.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    option domain-name "jujutsu.com";
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

service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart

#All Node
# 1. Request IP via DHCP
udhcpc -i eth0
# 2. Cek IP Address, Subnet Mask (/24), dan Broadcast Address
ip a show eth0
# 3. Cek Default Gateway (10.73.2.1 / 10.73.3.1)
ip route
# 4. Cek DNS Server (10.73.1.2, 10.73.1.3) dan Domain Search (jujutsu.com)
cat /etc/resolv.conf

#Tengen
cat /var/lib/dhcp/dhcpd.leases
grep -E "lease|hardware ethernet|binding state" /var/lib/dhcp/dhcpd.leases