#Kirara (API Worker cadangan, samakan API & koneksi ke Yaga)
#!/bin/sh

GETO_IP="10.73.4.2"

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

# 3. Tes koneksi ke Yaga
mysql -h 10.73.4.9 -u admin_net4 -ppassword123 -e "SELECT 1;" || { echo "GAGAL: tidak bisa login ke Yaga"; exit 1; }

#Nanami & Todo (pastikan hidup lagi setelah soal 18)
#!/bin/sh
service nginx start

# 4. API sama dengan Nanami/Todo (versi soal 17, ada client_ip)
mkdir -p /var/www/api
cat << 'ENDPHP' > /var/www/api/index.php
<?php
header('Content-Type: application/json');
mysqli_report(MYSQLI_REPORT_OFF);

$trusted_proxy = '10.73.4.2';
$client_ip = $_SERVER['REMOTE_ADDR'];
if ($_SERVER['REMOTE_ADDR'] === $trusted_proxy && !empty($_SERVER['HTTP_X_REAL_IP'])) {
    $candidate = trim($_SERVER['HTTP_X_REAL_IP']);
    if (filter_var($candidate, FILTER_VALIDATE_IP)) {
        $client_ip = $candidate;
    }
}

$db = @new mysqli('10.73.4.9', 'admin_net4', 'password123', 'db_shibuya_jujutsu');
if ($db->connect_errno) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'msg' => $db->connect_error]);
    exit;
}

$activity = 'API ' . gethostname() . ' ' . $_SERVER['REQUEST_METHOD'] . ' ' . $_SERVER['REQUEST_URI'];
$stmt = $db->prepare('INSERT INTO request_logs (activity, client_ip) VALUES (?, ?)');
$stmt->bind_param('ss', $activity, $client_ip);
$stmt->execute();

echo json_encode([
    'status' => 'ok',
    'worker' => gethostname(),
    'client_ip' => $client_ip,
    'logged' => $activity
]);
ENDPHP
chown -R www-data:www-data /var/www/api

# 5. Virtual host, hanya menerima Geto
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/web /etc/nginx/sites-enabled/api
cat << ENDCONF > /etc/nginx/sites-available/api
server {
    listen 80 default_server;
    server_name _;
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

# 6. Cek sintaks & restart
nginx -t && (service nginx restart || service nginx start)

# 7. Tes lokal (harus 403)
curl -s -o /dev/null -w "lokal (harus 403): %{http_code}\n" http://127.0.0.1/
grep -c client_ip /var/www/api/index.php

#Geto (Load Balancer + Backup + Passive Health Check)
#!/bin/sh

rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/proxy-api /etc/nginx/sites-enabled/api-lb
rm -f /etc/nginx/sites-available/proxy-api

cat << 'ENDCONF' > /etc/nginx/sites-available/api-lb
upstream api_cluster {
    server 10.73.4.5 weight=3 max_fails=2 fail_timeout=5s;
    server 10.73.4.6 weight=1 max_fails=2 fail_timeout=5s;
    server 10.73.4.7 backup;
}

server {
    listen 80 default_server;
    server_name _;

    set_real_ip_from 10.73.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $http_x_forwarded_for;
        proxy_connect_timeout 2s;
        proxy_next_upstream error timeout http_502 http_503 http_504;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/api-lb /etc/nginx/sites-enabled/api-lb

nginx -t && (service nginx restart || service nginx start)
cat /etc/nginx/sites-available/api-lb

#Nanami & Todo (Simulasi gangguan, jalankan di masing-masing node)
#!/bin/sh

service nginx stop

#Itadori (Pengujian: request /api harus dialihkan ke Kirara)
#!/bin/sh

echo "nameserver 10.73.1.2" > /etc/resolv.conf

# Semua harus HTTP 200, tidak ada 502
for i in $(seq 1 10); do curl -s -o /dev/null -w "HTTP %{http_code}\n" http://jujutsu.com/api; done

# Respons API valid dari Kirara
for i in $(seq 1 6); do curl -s http://jujutsu.com/api; echo; done

# Hitungan worker (semua kirara)
for i in $(seq 1 10); do curl -s http://jujutsu.com/api; done | grep -o '"worker":"[^"]*"' | sort | uniq -c

#Yaga (Bukti di database)
#!/bin/sh

mysql -u root -e "USE db_shibuya_jujutsu; SELECT id, activity, client_ip FROM request_logs ORDER BY id DESC LIMIT 10;"

#Nanami & Todo (Pemulihan, opsional)
#!/bin/sh

service nginx start