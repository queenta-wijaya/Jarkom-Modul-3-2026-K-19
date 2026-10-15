# Geto (Load Balancer API, soal 15)
#!/bin/sh

DOMAIN_API="ISI_DOMAIN_API"    # Sama dengan domain API di soal 14

# Upstream api_cluster: Weighted Round Robin 3:1 (Kirara tidak dipakai)
rm -f /etc/nginx/sites-enabled/default
cat << ENDCONF > /etc/nginx/sites-available/proxy-api
upstream api_cluster {
    server 10.73.4.5 weight=3;    # Nanami
    server 10.73.4.6 weight=1;    # Todo
}
server {
    listen 80 default_server;
    server_name $DOMAIN_API;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
ENDCONF
ln -sf /etc/nginx/sites-available/proxy-api /etc/nginx/sites-enabled/proxy-api

# Cek sintaks dulu, baru reload
nginx -t && (service nginx reload || service nginx restart)

# Tampilkan konfigurasi (bukti konfigurasi Geto)
cat /etc/nginx/sites-available/proxy-api

# Yaga (kosongkan log sebelum tes)
#!/bin/sh

mysql -u root -e "TRUNCATE db_shibuya_jujutsu.request_logs;"

# Maki (kirim 40 request dan hitung distribusi)
#!/bin/sh

DOMAIN_API="ISI_DOMAIN_API"    # Sama dengan domain API di Geto
GETO_IP="10.73.4.2"

# Kirim 40 request ke Geto, simpan hasil mentah
rm -f hasil.txt
for i in $(seq 1 40); do
  curl -s -H "Host: $DOMAIN_API" "http://$GETO_IP/" >> hasil.txt
  echo >> hasil.txt
done

# Tampilkan sebagian hasil untuk membuktikan worker bergantian
head -12 hasil.txt

# Hitung request per worker (berlaku untuk hostname apa pun)
echo "=== Hitungan per worker ==="
grep -o '"worker":"[^"]*"' hasil.txt | sort | uniq -c

# Rasio Nanami : Todo (sesuaikan hostname bila berbeda)
N=$(grep -c '"worker":"nanami"' hasil.txt)
T=$(grep -c '"worker":"todo"' hasil.txt)
echo "Nanami = $N, Todo = $T"
echo "Rasio Nanami : Todo = $N : $T (target 3 : 1)"

# Yaga (bukti tambahan, opsional)
#!/bin/sh

mysql -u root -e "SELECT activity, COUNT(*) AS jumlah FROM db_shibuya_jujutsu.request_logs GROUP BY activity;"