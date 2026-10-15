#Utahime (DNS Master)
#!/bin/sh

# 1. Update Konfigurasi Named Options (Forwarder & DNSSEC)
cat << 'EOF' > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query { any; };
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
        dnssec-validation no;
};
EOF

# 2. Update Konfigurasi Named Local (Tambah Zone Reverse PTR)
cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.com" {
    type master;
    file "/etc/bind/jujutsu/jujutsu.com";
    allow-transfer { 10.73.1.3; };
    also-notify { 10.73.1.3; };
};

zone "1.73.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jujutsu/1.73.10.in-addr.arpa";
    allow-transfer { 10.73.1.3; };
    also-notify { 10.73.1.3; };
};
EOF

# 3. Update Zone File Forward jujutsu.com (A Record Gojo & CNAME www)
cat << 'EOF' > /etc/bind/jujutsu/jujutsu.com
$TTL    604800
@       IN      SOA     utahime.jujutsu.com. admin.jujutsu.com. (
                              2026101303 ; Serial dinaikkan
                                  604800 ; Refresh
                                   86400 ; Retry
                                 2419200 ; Expire
                                  604800 ) ; Negative Cache TTL
;
; Name Servers
@       IN      NS      utahime.jujutsu.com.
@       IN      NS      shoko.jujutsu.com.

; A Records Name Servers & Domain Utama (A Record Gojo)
utahime IN      A       10.73.1.2
shoko   IN      A       10.73.1.3
gojo    IN      A       10.73.1.4
@       IN      A       10.73.1.4

; CNAME Record www
www     IN      CNAME   jujutsu.com.
EOF

# 4. Buat Reverse Zone File (1.73.10.in-addr.arpa)
cat << 'EOF' > /etc/bind/jujutsu/1.73.10.in-addr.arpa
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

; PTR Records (10.73.1.x)
2       IN      PTR     utahime.jujutsu.com.
3       IN      PTR     shoko.jujutsu.com.
4       IN      PTR     gojo.jujutsu.com.
EOF

# 5. Validasi Sintaks Konfigurasi & Reload Service
named-checkconf
named-checkzone jujutsu.com /etc/bind/jujutsu/jujutsu.com
named-checkzone 1.73.10.in-addr.arpa /etc/bind/jujutsu/1.73.10.in-addr.arpa

service named restart || service bind9 restart || rndc reload

#Shoko (DNS Slave)
#!/bin/sh

cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.com" {
    type slave;
    masters { 10.73.1.2; };
    file "/var/lib/bind/jujutsu.com";
};

zone "1.73.10.in-addr.arpa" {
    type slave;
    masters { 10.73.1.2; };
    file "/var/lib/bind/1.73.10.in-addr.arpa";
};
EOF

named-checkconf
service named restart || service bind9 restart

#Itadori
#!/bin/sh

# 1. Pastikan DNS Client menunjuk ke Utahime
echo "nameserver 10.73.1.2" > /etc/resolv.conf

# 2. Uji CNAME Record www.jujutsu.com
dig @10.73.1.2 www.jujutsu.com CNAME

# 3. Uji A Record jujutsu.com (Harus mengarah ke IP Gojo: 10.73.1.4)
dig @10.73.1.2 jujutsu.com A

# 4. Uji Reverse DNS / PTR Record untuk IP Gojo (10.73.1.4)
dig @10.73.1.2 -x 10.73.1.4

# 5. Uji DNS Forwarder & Ping ke domain luar/internet (google.com)
ping -c 2 google.com