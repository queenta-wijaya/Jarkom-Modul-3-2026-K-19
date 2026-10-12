#Tengen
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# ==========================================
# DEFINISI KELAS NETWORK 2 (DIVISI A) - SOAL 4
# ==========================================
class "dev-team" {
    match if hardware = 1:02:42:c0:a6:93:00 or
             hardware = 1:02:42:f9:82:71:00;
}

class "support-team" {
    match if hardware = 1:02:42:80:8b:ed:00 or
             hardware = 1:02:42:d3:9d:2d:00;
}

# ==========================================
# DEFINISI KELAS NETWORK 3 (DIVISI B) - SOAL 5
# ==========================================
# Short Lease: ino & kusakabe
class "short-lease-clients" {
    match if hardware = 1:02:42:53:99:4e:00 or
             hardware = 1:02:42:82:1f:d5:00;
}

# Long Lease: miwa
class "long-lease-clients" {
    match if hardware = 1:02:42:18:10:54:00;
}

# ==========================================
# SUBNET DEFINITIONS
# ==========================================

# Subnet Lokal Network 4 (Data Center)
subnet 10.73.4.0 netmask 255.255.255.0 {
}

# Subnet Network 2 (Divisi A)
subnet 10.73.2.0 netmask 255.255.255.0 {
    option routers 10.73.2.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;

    pool {
        allow members of "dev-team";
        range 10.73.2.10 10.73.2.35;
    }

    pool {
        allow members of "support-team";
        range 10.73.2.70 10.73.2.95;
    }
}

# Subnet Network 3 (Divisi B) - SOAL 5
subnet 10.73.3.0 netmask 255.255.255.0 {
    option routers 10.73.3.1;
    option domain-name-servers 10.73.1.2, 10.73.1.3;
    option domain-search "jujutsu.com";

    # Pool 1: Short Lease (ino & kusakabe) -> 1800 detik (30 menit)
    pool {
        allow members of "short-lease-clients";
        range 10.73.3.10 10.73.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Pool 2: Long Lease (miwa) -> 43200 detik (12 jam)
    pool {
        allow members of "long-lease-clients";
        range 10.73.3.100 10.73.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
EOF

# Validasi Syntax & Restart Service
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart

#Ino, Kusakabe, Miwa
dhclient -r eth0 && dhclient -v eth0

#Jangan lupa di Ino, Kusakabe, Miwa:
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install -y isc-dhcp-client ifupdown