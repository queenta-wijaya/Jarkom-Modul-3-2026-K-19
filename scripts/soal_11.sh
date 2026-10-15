#Jichi 
ip link set eth0 up
ip link set eth2 up
ip addr replace 10.73.1.1/24 dev eth0
ip addr replace 10.73.2.1/24 dev eth2
sysctl -w net.ipv4.ip_forward=1

# NAT supaya utahime/shoko bisa apt-get lewat Jichi (eth1 = sisi NAT/internet)
iptables -t nat -C POSTROUTING -o eth1 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

ip a
ip route

#utahime (DNS Master)
#!/bin/sh
ip link set eth0 up
ip addr replace 10.73.1.2/24 dev eth0
ip route replace default via 10.73.1.1
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# cek konektivitas dulu sebelum install
ping -c 2 10.73.1.1 || echo "GAGAL: gateway Jichi belum aktif"

apt-get update && apt-get install -y bind9 bind9utils bind9-dnsutils dnsutils

mkdir -p /etc/bind/jujutsu

cat << 'EOF' > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
                8.8.8.8;
        };
        allow-query { any; };
        auth-nxdomain no;
        listen-on-v6 { any; };
};
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.com" {
    type master;
    file "/etc/bind/jujutsu/jujutsu.com";
    allow-transfer { 10.73.1.3; };
    also-notify { 10.73.1.3; };
};
EOF

cat << 'EOF' > /etc/bind/jujutsu/jujutsu.com
$TTL    604800
@       IN      SOA     utahime.jujutsu.com. admin.jujutsu.com. (
                              2026101301 ; Serial
                                  604800 ; Refresh
                                   86400 ; Retry
                                 2419200 ; Expire
                                  604800 ) ; Negative Cache TTL
;
@       IN      NS      utahime.jujutsu.com.
@       IN      NS      shoko.jujutsu.com.

utahime IN      A       10.73.1.2
shoko   IN      A       10.73.1.3
@       IN      A       10.73.1.2
EOF

named-checkconf
named-checkzone jujutsu.com /etc/bind/jujutsu/jujutsu.com
service named restart || service bind9 restart

#shoko (DNS Slave)
#!/bin/sh
#!/bin/sh
ip link set eth0 up
ip addr replace 10.73.1.3/24 dev eth0
ip route replace default via 10.73.1.1
echo "nameserver 8.8.8.8" > /etc/resolv.conf

ping -c 2 10.73.1.1 || echo "GAGAL: gateway Jichi belum aktif"

apt-get update && apt-get install -y bind9 bind9utils bind9-dnsutils dnsutils

mkdir -p /etc/bind

cat << 'EOF' > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
                8.8.8.8;
        };
        allow-query { any; };
        auth-nxdomain no;
        listen-on-v6 { any; };
};
EOF

cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.com" {
    type slave;
    masters { 10.73.1.2; };
    file "/var/lib/bind/jujutsu.com";
};
EOF

named-checkconf
ls -la /var/lib/bind/
service named restart || service bind9 restart

#Itadori 
# Routing ke Gateway Jichi
ip link set eth0 up
ip addr replace 10.73.2.2/24 dev eth0
ip route replace default via 10.73.2.1
ip a
ip route
ping -c 2 10.73.2.1
ping -c 2 10.73.1.2
ping -c 2 10.73.1.3

# Pengujian Query DNS
dig @10.73.1.2 jujutsu.com SOA
dig @10.73.1.3 jujutsu.com SOA