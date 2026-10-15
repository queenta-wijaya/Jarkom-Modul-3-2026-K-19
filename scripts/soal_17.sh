#Yaga (tambah kolom client_ip)
#!/bin/sh

DB="db_shibuya_jujutsu"

# Pakai USE supaya tercatat di binlog dan terreplikasi ke Inumaki
mysql -u root -e "USE $DB; ALTER TABLE request_logs ADD COLUMN IF NOT EXISTS client_ip VARCHAR(45) NULL;"
mysql -u root -e "USE $DB; DESCRIBE request_logs;"

#Nanami, Todo, Kirara (API Worker, simpan client_ip)
#!/bin/sh

cat << 'ENDPHP' > /var/www/api/index.php
<?php
header('Content-Type: application/json');
mysqli_report(MYSQLI_REPORT_OFF);

// Percaya X-Real-IP hanya jika pengirim langsung adalah Geto
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
chown www-data:www-data /var/www/api/index.php

grep -c client_ip /var/www/api/index.php
curl -s -o /dev/null -w "lokal (harus 403): %{http_code}\n" http://127.0.0.1/

#Geto (Load Balancer + Trusted Proxy)
#!/bin/sh

rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/proxy-api /etc/nginx/sites-enabled/api-lb
rm -f /etc/nginx/sites-available/proxy-api

cat << 'ENDCONF' > /etc/nginx/sites-available/api-lb
upstream api_cluster {
    server 10.73.4.5 weight=3;    # nanami
    server 10.73.4.6 weight=1;    # todo
}

server {
    listen 80 default_server;
    server_name _;

    # Hanya header dari Gojo yang dipercaya
    set_real_ip_from 10.73.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $http_x_forwarded_for;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/api-lb /etc/nginx/sites-enabled/api-lb

nginx -t && (service nginx restart || service nginx start)

#Gojo (Gateway, X-Real-IP & X-Forwarded-For)
#!/bin/sh

DOMAIN="jujutsu.com"    # ganti sesuai <xxxx> di soal

rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/gateway
cat << 'ENDCONF' > /etc/nginx/sites-available/gateway
upstream web_cluster {
    server 10.73.4.3;    # maki
    server 10.73.4.4;    # panda
}

server {
    listen 80 default_server;
    server_name __DOMAIN__ www.__DOMAIN__;

    location / {
        proxy_pass http://web_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location /api {
        proxy_pass http://10.73.4.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
ENDCONF
sed -i "s/__DOMAIN__/$DOMAIN/g" /etc/nginx/sites-available/gateway
ln -sf /etc/nginx/sites-available/gateway /etc/nginx/sites-enabled/gateway

nginx -t && (service nginx restart || service nginx start)
grep -n "X-Forwarded-For\|X-Real-IP" /etc/nginx/sites-available/gateway

#Itadori (Klien Network 2)
#!/bin/sh

echo "nameserver 10.73.1.2" > /etc/resolv.conf
ip -4 a show eth0
for i in 1 2 3 4 5 6 7 8; do curl -s http://jujutsu.com/api; echo; done

# Uji pemalsuan header: client_ip harus tetap 10.73.2.2
curl -s -H "X-Forwarded-For: 1.2.3.4" -H "X-Real-IP: 1.2.3.4" http://jujutsu.com/api; echo

#Klien Network 3 (ino / kusakabe / kugisaki / mimi, pilih yang 10.73.3.x)
#!/bin/sh

hostname
ip -4 a show eth0
echo "nameserver 10.73.1.2" > /etc/resolv.conf
ip route add default via 10.73.3.1 2>/dev/null
for i in 1 2 3 4 5 6 7 8; do curl -s http://jujutsu.com/api; echo; done

#Yaga (bukti di database, jalankan setelah kedua klien tes)
#!/bin/sh

mysql -u root -e "USE db_shibuya_jujutsu; SELECT id, activity, client_ip FROM request_logs WHERE client_ip LIKE '10.73.2.%' OR client_ip LIKE '10.73.3.%' ORDER BY id DESC LIMIT 12;"