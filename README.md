# Jarkom-Modul-3-2026-K-19

## Anggota Kelompok

| Nama | NRP |
| --- | --- |
| Ni Putu Maqueenta Wijaya | 5027251004 |
| Malikha Syafira Dewi | 5027251032 |

## Pembahasan
## Soal 1 — Konfigurasi jaringan dan routing

Jichi berperan sebagai router yang menghubungkan jaringan `10.73.1.0/24`, `10.73.2.0/24`, `10.73.3.0/24`, dan `10.73.4.0/24`. Antarmuka internal diberi alamat gateway `.1` pada masing-masing subnet, sedangkan node lain dikonfigurasi menggunakan alamat statis sesuai jaringannya. Pada Jichi, IP forwarding diaktifkan dan NAT `MASQUERADE` dipasang pada antarmuka yang mengarah ke jaringan luar. Dengan begitu, node-node pada jaringan internal dapat meneruskan lalu lintas melalui router.

Pengujian ping pada beberapa node menunjukkan bahwa koneksi antarnode dan gateway dapat dijangkau.

**Jichi — router**

```bash
auto eth0 eth1 eth2 eth3 eth4

iface eth0 inet dhcp

iface eth1 inet static
    address 10.73.1.1
    netmask 255.255.255.0

iface eth2 inet static
    address 10.73.2.1
    netmask 255.255.255.0

iface eth3 inet static
    address 10.73.3.1
    netmask 255.255.255.0

iface eth4 inet static
    address 10.73.4.1
    netmask 255.255.255.0

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth1 eth2 eth3 eth4 2>/dev/null || (ip addr add 10.73.1.1/24 dev eth1; ip addr add 10.73.2.1/24 dev eth2; ip addr add 10.73.3.1/24 dev eth3; ip addr add 10.73.4.1/24 dev eth4)

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

ip addr add 192.168.122.100/24 dev eth0 2>/dev/null
ip link set eth0 up
ip route add default via 192.168.122.1 2>/dev/null
```

**Utahime — `10.73.1.2/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.1.2
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Shoko — `10.73.1.3/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.1.3
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Gojo — `10.73.1.4/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.1.4
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Itadori, Fushiguro, Zenin, dan Okkotsu — klien DHCP Network 2**

```bash
auto eth0

iface eth0 inet dhcp
echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Ino, Kusakabe, Kugisaki, dan Miwa — klien DHCP Network 3**

```bash
auto eth0

iface eth0 inet dhcp
echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Geto — `10.73.4.2/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.2
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Maki — `10.73.4.3/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.3
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Panda — `10.73.4.4/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.4
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Nanami — `10.73.4.5/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.5
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Todo — `10.73.4.6/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.6
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Kirara — `10.73.4.7/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.7
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Tengen — `10.73.4.8/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.8
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Yaga — `10.73.4.9/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.9
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

**Inumaki — `10.73.4.10/24`**

```bash
auto eth0

iface eth0 inet static
    address 10.73.4.10
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart
```

![Uji konektivitas jaringan](./assets/soal_1-1.png)
![Uji koneksi dari node](./assets/soal_1-2.png)
![Uji koneksi antarnode](./assets/soal_1-3.png)
![Uji koneksi ke gateway](./assets/soal_1-4.png)

## Soal 2 — Konfigurasi DHCP server

Di Tengen dipasang layanan `isc-dhcp-server` dan antarmuka layanan ditetapkan ke `eth0`. Konfigurasi awal menyediakan pool untuk Network 2 (`10.73.2.2–10.73.2.254`) dan Network 3 (`10.73.3.2–10.73.3.254`), dengan gateway masing-masing `.2.1` dan `.3.1`, serta DNS `10.73.1.2` dan `10.73.1.3`. Sebelum instalasi, koneksi keluar diuji agar repositori paket dapat diakses; ping pada tangkapan layar menunjukkan gateway luar dan alamat publik merespons.

**Tengen — instalasi dan konfigurasi DHCP server**

```bash
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
```

![Pengujian koneksi ke jaringan luar](./assets/soal_2.png)

## Soal 3 — Konfigurasi DHCP relay

DHCP relay dipasang pada Jichi agar permintaan DHCP dari jaringan yang berbeda dapat diteruskan ke Tengen di `10.73.4.8`. Relay dikonfigurasi untuk mendengarkan antarmuka `eth2`, `eth3`, dan `eth4`, lalu permintaan alamat diuji dari klien menggunakan `udhcpc`.

Tangkapan layar berikut merupakan pengujian konektivitas pada jaringan yang digunakan dalam konfigurasi, bukan output langsung dari proses DHCP relay.

**Jichi — instalasi dan konfigurasi DHCP relay**

```bash
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
```

**Itadori — meminta alamat melalui DHCP**

```bash
# Set DNS sementara (ke NAT1 / Google)
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# Testing
udhcpc -i eth0
```

![Pengujian koneksi jaringan](./assets/soal_3-1.png)
![Pengujian koneksi lanjutan](./assets/soal_3-2.png)

## Soal 4 — Pembagian alamat DHCP berdasarkan kelas klien

Konfigurasi DHCP membagi klien Network 2 ke dalam dua kelas berdasarkan alamat MAC. Klien Dev Team memperoleh alamat dari rentang `10.73.2.10–10.73.2.35`, sedangkan Support Team memperoleh alamat dari rentang `10.73.2.70–10.73.2.95`. Setelah konfigurasi diterapkan, layanan DHCP direstart dan klien meminta alamat melalui `udhcpc`.

**Tengen — kelas klien dan konfigurasi pool DHCP**

```bash
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
    option domain-name "jujutsu.com";
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
    option domain-name "jujutsu.com";
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
```

**Itadori dan Fushiguro — klien kelas Dev Team**

```bash
udhcpc -i eth0
```

**Zenin dan Okkotsu — klien kelas Support Team**

```bash
udhcpc -i eth0
```

![Validasi layanan DHCP](./assets/soal_4-0.png)
![Alamat DHCP untuk klien](./assets/soal_4-1.png)
![Pengujian DHCP klien berikutnya](./assets/soal_4-2.png)
![Pengujian DHCP klien](./assets/soal_4-3.png)
![Pengujian DHCP klien](./assets/soal_4-4.png)

## Soal 5 — Pengaturan durasi lease

Pada Network 3, kelas klien digunakan untuk membedakan rentang alamat dan lama lease. Klien dengan lease pendek mendapat alamat dari `10.73.3.10–10.73.3.89` dengan durasi 1.800 detik (30 menit). Klien dengan lease panjang mendapat alamat dari `10.73.3.100–10.73.3.199` dengan durasi 43.200 detik (12 jam). Nilai durasi tersebut ditetapkan sebagai `default-lease-time` dan `max-lease-time` pada masing-masing pool.

**Tengen — kelas klien dan lease Network 3**

```bash
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

class "dev-team" {
    match if hardware = 1:02:42:d6:17:eb:00 or
             hardware = 1:02:42:58:7f:b4:00;
}

class "support-team" {
    match if hardware = 1:02:42:0c:74:7a:00 or
             hardware = 1:02:42:80:05:e5:00;
}

class "short-lease-clients" {
    match if hardware = 1:02:42:87:5f:a1:00 or
             hardware = 1:02:42:61:7e:7f:00;
}

class "long-lease-clients" {
    match if hardware = 1:02:42:ac:34:54:00;
}

host kugisaki {
    hardware ethernet f2:dd:ec:51:c9:cb;
    fixed-address 10.73.3.99;
}

subnet 10.73.4.0 netmask 255.255.255.0 {
}

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

service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart
```

**Ino, Kusakabe, dan Miwa — meminta lease dari DHCP**

```bash
udhcpc -i eth0
```

![Uji lease klien](./assets/soal_5-1.png)
![Uji lease klien berikutnya](./assets/soal_5-2.png)
![Uji lease klien dengan durasi panjang](./assets/soal_5-3.png)

## Soal 6 — Reservasi alamat untuk Kugisaki

Reservasi DHCP yang didefinisikan pada konfigurasi server mengikat alamat MAC Kugisaki ke alamat `10.73.3.99`. Kugisaki meminta konfigurasi melalui `udhcpc`, lalu alamat pada antarmuka, rute default, dan DNS diperiksa. Hasilnya menunjukkan bahwa klien menerima alamat reservasi beserta parameter jaringan dari server.

**Tengen — konfigurasi DHCP dengan reservasi Kugisaki**

```bash
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

class "dev-team" {
    match if hardware = 1:02:42:d6:17:eb:00 or
             hardware = 1:02:42:58:7f:b4:00;
}

class "support-team" {
    match if hardware = 1:02:42:0c:74:7a:00 or
             hardware = 1:02:42:80:05:e5:00;
}

class "short-lease-clients" {
    match if hardware = 1:02:42:87:5f:a1:00 or
             hardware = 1:02:42:61:7e:7f:00;
}

class "long-lease-clients" {
    match if hardware = 1:02:42:ac:34:54:00;
}

host kugisaki {
    hardware ethernet 02:42:c4:b9:32:00;
    fixed-address 10.73.3.99;
}

subnet 10.73.4.0 netmask 255.255.255.0 {
}

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

# Validasi sintaks dan restart layanan DHCP
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart
```

**Kugisaki — meminta alamat reservasi**

```bash
udhcpc -i eth0
```

![Verifikasi alamat DHCP Kugisaki](./assets/soal_6.png)

## Soal 7 — Verifikasi parameter DHCP dan lease klien

Selain alamat IP, server memberikan subnet mask `/24`, alamat broadcast, default gateway, DNS `10.73.1.2` dan `10.73.1.3`, serta domain pencarian `jujutsu.com`. Pengaturan ini diterapkan pada subnet Network 2 dan Network 3. Konfigurasi klien diperiksa menggunakan `ip a`, `ip route`, dan `/etc/resolv.conf`; catatan lease pada Tengen juga diperiksa untuk memastikan alamat telah terikat pada klien.

**Tengen — konfigurasi DHCP, verifikasi lease**

```bash
cat << 'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

class "dev-team" {
    match if hardware = 1:02:42:d6:17:eb:00 or
             hardware = 1:02:42:58:7f:b4:00;
}

class "support-team" {
    match if hardware = 1:02:42:0c:74:7a:00 or
             hardware = 1:02:42:80:05:e5:00;
}

class "short-lease-clients" {
    match if hardware = 1:02:42:87:5f:a1:00 or
             hardware = 1:02:42:61:7e:7f:00;
}

class "long-lease-clients" {
    match if hardware = 1:02:42:ac:34:54:00;
}

host kugisaki {
    hardware ethernet 02:42:c4:b9:32:00;
    fixed-address 10.73.3.99;
}

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

# Periksa lease yang tercatat pada server
cat /var/lib/dhcp/dhcpd.leases
grep -E "lease|hardware ethernet|binding state" /var/lib/dhcp/dhcpd.leases
```

**Klien Network 2 dan Network 3 — meminta IP dan memeriksa konfigurasi**

```bash
udhcpc -i eth0
ip a show eth0
ip route
cat /etc/resolv.conf
```

![Pemeriksaan parameter DHCP](./assets/soal_7-1.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-2.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-3.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-4.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-5.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-6.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-7.png)
![Pemeriksaan konfigurasi klien](./assets/soal_7-8.png)
![Pemeriksaan konfigurasi lease](./assets/soal_7-9.png)
![Pemeriksaan catatan lease pada server](./assets/soal_7-10.png)
![Pengujian ulang permintaan DHCP](./assets/soal_7-11.png)

## Soal 8 — Pengujian DHCP relay

Layanan DHCP relay pada Jichi dihentikan dan dijalankan kembali. Setelah relay aktif, klien di Network 2 meminta alamat menggunakan `udhcpc`. Klien memperoleh lease dari Tengen melalui relay, yang menunjukkan bahwa permintaan lintas subnet dapat diteruskan.

**Tengen — menangkap paket DHCP**

```bash
tcpdump -i eth0 -nvv "port 67 or port 68"
```

**Itadori — meminta lease dengan mode gagal cepat**

```bash
udhcpc -i eth0 -n -q
```

![Pengujian DHCP klien setelah relay dijalankan](./assets/soal_8-1.png)

## Soal 9 — Restart DHCP server dan relay

Layanan DHCP server di Tengen dan DHCP relay di Jichi direstart, kemudian masing-masing dihentikan dan dijalankan kembali. Klien meminta lease setelah layanan aktif. Catatan lease di server turut diperiksa untuk melihat alamat yang telah diberikan.

**Jichi — hentikan lalu jalankan DHCP relay**

```bash
# Matikan relay
service isc-dhcp-relay stop || /etc/init.d/isc-dhcp-relay stop

# Nyalakan kembali relay
service isc-dhcp-relay start || /etc/init.d/isc-dhcp-relay start
```

**Itadori — uji permintaan DHCP**

```bash
udhcpc -i eth0 -n -q
```

![Pengujian klien setelah relay dijalankan](./assets/soal_9-1.png)
![Pemeriksaan catatan lease DHCP](./assets/soal_9-2.png)

## Soal 10 — Validasi permintaan DHCP setelah restart

Pengujian diulangi dengan merestart DHCP server dan relay, lalu menghentikan dan menjalankan kembali kedua layanan. Setelah itu klien meminta lease melalui `udhcpc`. Tangkapan layar digunakan untuk memeriksa bahwa layanan kembali berjalan dan respons DHCP diterima oleh klien.

**Tengen — restart DHCP server**

```bash
service isc-dhcp-server restart || /etc/init.d/isc-dhcp-server restart
service isc-dhcp-server stop && service isc-dhcp-server start
```

**Jichi — restart DHCP relay**

```bash
service isc-dhcp-relay restart || /etc/init.d/isc-dhcp-relay restart
service isc-dhcp-relay stop && service isc-dhcp-relay start
```

**Itadori — uji permintaan DHCP**

```bash
udhcpc -i eth0 -n -q
```

![Validasi layanan DHCP setelah restart](./assets/soal_10-1.png)
![Hasil permintaan DHCP setelah layanan aktif](./assets/soal_10-2.png)
