# Maki & Panda (Web Worker)
#!/bin/sh

PROXY_WEB_IP="10.73.1.4"       # IP proxy web (Gojo)
DOMAIN_WEB="ISI_DOMAIN_WEB"    # Domain web dari soal

# 1. Jalur ke Jichi & DNS
ip route add default via 10.73.4.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install Nginx + PHP-FPM
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx php-fpm curl

# 3. Jalankan PHP-FPM & cari socket-nya
PHPV=$(ls /etc/php | head -1)
service php$PHPV-fpm restart || service php$PHPV-fpm start
sleep 2
SOCK=$(ls /run/php/php*-fpm.sock | head -1)
echo "PHP-FPM socket: $SOCK"

# 4. Halaman web: tampilkan hostname
mkdir -p /var/www/web
cat << 'ENDPHP' > /var/www/web/index.php
<?php
echo "<h1>Web Worker</h1>";
echo "<p>Hostname: " . gethostname() . "</p>";
echo "<p>Client (di mata worker): " . $_SERVER['REMOTE_ADDR'] . "</p>";
ENDPHP
chown -R www-data:www-data /var/www/web

# 5. Virtual host + hanya menerima trafik dari proxy web
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/web /etc/nginx/sites-enabled/api
cat << ENDCONF > /etc/nginx/sites-available/web
server {
    listen 80 default_server;
    server_name $DOMAIN_WEB;
    root /var/www/web;
    index index.php;

    allow $PROXY_WEB_IP;
    deny all;

    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$SOCK;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web

# 6. Cek sintaks & restart Nginx
nginx -t && (service nginx restart || service nginx start)

# 7. Tes lokal (harus 403 karena 127.0.0.1 bukan IP proxy)
curl -s -o /dev/null -w "lokal (harus 403): %{http_code}\n" http://127.0.0.1/

# Nanami, Todo, Kirara (API Worker)
#!/bin/sh

GETO_IP="10.73.4.2"            # Hanya Geto yang boleh akses
DOMAIN_API="ISI_DOMAIN_API"    # Domain API dari soal
DB="db_shibuya_jujutsu"

# 1. Jalur ke Jichi & DNS
ip route add default via 10.73.4.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install Nginx + PHP-FPM + driver MySQL + client
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx php-fpm php-mysql curl mariadb-client

PHPV=$(ls /etc/php | head -1)
service php$PHPV-fpm restart || service php$PHPV-fpm start
sleep 2
SOCK=$(ls /run/php/php*-fpm.sock | head -1)
echo "PHP-FPM socket: $SOCK"

# 3. Tes koneksi ke database Yaga (script Yaga harus sudah dijalankan)
mysql -h 10.73.4.9 -u admin_net4 -ppassword123 -e "SELECT 1;" || { echo "GAGAL: tidak bisa login ke Yaga"; exit 1; }

# 4. API: catat setiap request ke tabel request_logs di Yaga
mkdir -p /var/www/api
cat << ENDPHP > /var/www/api/index.php
<?php
header('Content-Type: application/json');
mysqli_report(MYSQLI_REPORT_OFF);
\$db = @new mysqli('10.73.4.9', 'admin_net4', 'password123', '$DB');
if (\$db->connect_errno) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'msg' => \$db->connect_error]);
    exit;
}
\$activity = 'API ' . gethostname() . ' ' . \$_SERVER['REQUEST_METHOD'] . ' ' . \$_SERVER['REQUEST_URI'];
\$stmt = \$db->prepare('INSERT INTO request_logs (activity) VALUES (?)');
\$stmt->bind_param('s', \$activity);
\$stmt->execute();
echo json_encode(['status' => 'ok', 'worker' => gethostname(), 'logged' => \$activity]);
ENDPHP
chown -R www-data:www-data /var/www/api

# 5. Virtual host + hanya menerima trafik dari Geto
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/web /etc/nginx/sites-enabled/api
cat << ENDCONF > /etc/nginx/sites-available/api
server {
    listen 80 default_server;
    server_name $DOMAIN_API;
    root /var/www/api;
    index index.php;

    allow $GETO_IP;
    deny all;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$SOCK;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/api /etc/nginx/sites-enabled/api

# 6. Cek sintaks & restart Nginx
nginx -t && (service nginx restart || service nginx start)

# 7. Tes lokal (harus 403 karena 127.0.0.1 bukan Geto)
curl -s -o /dev/null -w "lokal (harus 403): %{http_code}\n" http://127.0.0.1/

# Geto (Proxy API)
#!/bin/sh

DOMAIN_API="ISI_DOMAIN_API"    # Sama dengan di API worker

# 1. Jalur ke Jichi & DNS
ip route add default via 10.73.4.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install Nginx
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx curl

# 3. Reverse proxy ke 3 API worker (Nanami, Todo, Kirara)
rm -f /etc/nginx/sites-enabled/default
cat << ENDCONF > /etc/nginx/sites-available/proxy-api
upstream api_workers {
    server 10.73.4.5;
    server 10.73.4.6;
    server 10.73.4.7;
}
server {
    listen 80 default_server;
    server_name $DOMAIN_API;

    location / {
        proxy_pass http://api_workers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/proxy-api /etc/nginx/sites-enabled/proxy-api

nginx -t && (service nginx restart || service nginx start)

# 4. Tes lewat proxy sendiri (harus bergantian antar worker)
for i in 1 2 3; do curl -s -H "Host: $DOMAIN_API" http://127.0.0.1/; echo; done

# Gojo (Proxy Web)
#!/bin/sh

DOMAIN_WEB="ISI_DOMAIN_WEB"    # Sama dengan di Maki & Panda

# 1. Jalur ke Jichi & DNS
ip route add default via 10.73.1.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install Nginx
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx curl

# 3. Reverse proxy ke Maki & Panda
rm -f /etc/nginx/sites-enabled/default
cat << ENDCONF > /etc/nginx/sites-available/proxy-web
upstream web_workers {
    server 10.73.4.3;
    server 10.73.4.4;
}
server {
    listen 80 default_server;
    server_name $DOMAIN_WEB;

    location / {
        proxy_pass http://web_workers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/proxy-web /etc/nginx/sites-enabled/proxy-web

nginx -t && (service nginx restart || service nginx start)

# 4. Tes lewat proxy sendiri (hostname Maki/Panda harus bergantian)
for i in 1 2 3 4; do curl -s -H "Host: $DOMAIN_WEB" http://127.0.0.1/ | grep Hostname; done

# Pengujian (jalankan dari container yang disebutkan)
#
# Dari Itadori: akses langsung ke semua worker harus ditolak (403).
# curl -i http://10.73.4.3/
# curl -i http://10.73.4.4/
# curl -i http://10.73.4.5/
# curl -i http://10.73.4.6/
# curl -i http://10.73.4.7/
#
# Dari Gojo: akses lewat proxy web berhasil.
# curl -i -H "Host: ISI_DOMAIN_WEB" http://127.0.0.1/
#
# Dari Geto: akses lewat proxy API berhasil (200 OK, JSON status ok).
# curl -i -H "Host: ISI_DOMAIN_API" http://127.0.0.1/
#
# Di Yaga: bukti log tercatat.
# mysql -u root -e "USE db_shibuya_jujutsu; SELECT * FROM request_logs ORDER BY id DESC LIMIT 5;"
#
# Dari Itadori: akses web melalui proxy (opsional).
# curl -i -H "Host: ISI_DOMAIN_WEB" http://10.73.1.4/
