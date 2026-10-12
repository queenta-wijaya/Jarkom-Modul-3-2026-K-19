#Jichi
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

#Utahime
auto eth0

iface eth0 inet static
    address 10.73.1.2
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Shoko
auto eth0

iface eth0 inet static
    address 10.73.1.3
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Gojo
auto eth0

iface eth0 inet static
    address 10.73.1.4
    netmask 255.255.255.0
    gateway 10.73.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Itadori, Fushiguro, Zenin, Okkotsu
auto eth0

iface eth0 inet dhcp
echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Ino, Kusakabe, Kugisaki, Miwa
auto eth0

iface eth0 inet dhcp
echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Geto
auto eth0

iface eth0 inet static
    address 10.73.4.2
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Maki
auto eth0

iface eth0 inet static
    address 10.73.4.3
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Panda
auto eth0

iface eth0 inet static
    address 10.73.4.4
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Nanami
auto eth0

iface eth0 inet static
    address 10.73.4.5
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Todo
auto eth0

iface eth0 inet static
    address 10.73.4.6
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Kirara
auto eth0

iface eth0 inet static
    address 10.73.4.7
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Tengen
auto eth0

iface eth0 inet static
    address 10.73.4.8
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Yaga
auto eth0

iface eth0 inet static
    address 10.73.4.9
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart

#Inumaki
auto eth0

iface eth0 inet static
    address 10.73.4.10
    netmask 255.255.255.0
    gateway 10.73.4.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service networking restart