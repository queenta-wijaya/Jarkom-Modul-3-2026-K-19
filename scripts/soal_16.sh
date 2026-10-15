#Gojo (Gateway Publik, Path-Based Routing)
#!/bin/sh

DOMAIN="jujutsu.com"    # ganti sesuai <xxxx> di soal, mis. jujutsu.k19.com

# 1. Jalur ke Jichi & DNS
ip route add default via 10.73.1.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install Nginx
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx curl

# 3. Virtual host path-based
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/proxy-web /etc/nginx/sites-enabled/gateway
cat << ENDCONF > /etc/nginx/sites-available/gateway
upstream web_cluster {
    server 10.73.4.3;    # maki
    server 10.73.4.4;    # panda
}

server {
    listen 80 default_server;
    server_name $DOMAIN www.$DOMAIN;


    location / {
        proxy_pass http://web_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }


    location /api {
        proxy_pass http://10.73.4.2;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/gateway /etc/nginx/sites-enabled/gateway

# 4. Cek sintaks & restart
nginx -t && (service nginx restart || service nginx start)

# 5. Tes dari Gojo sendiri
for i in 1 2 3 4; do curl -s -H "Host: $DOMAIN" http://127.0.0.1/ | grep Hostname; done
for i in 1 2 3 4; do curl -s -H "Host: $DOMAIN" http://127.0.0.1/api; echo; done

#Itadori (Client Divisi A/B, Pengujian)
#!/bin/sh

# 1. Pastikan DNS & route
echo "nameserver 10.73.1.2" > /etc/resolv.conf
ip route add default via 10.73.2.1 2>/dev/null

# 2. Web utama: dibalas Maki/Panda bergantian
for i in 1 2 3 4; do curl -s http://jujutsu.com/ | grep Hostname; done

# 3. Domain www
curl -s http://www.jujutsu.com/ | grep Hostname

# 4. Path /api: dibalas Nanami/Todo
for i in 1 2 3 4 5 6 7 8; do curl -s http://jujutsu.com/api; echo; done