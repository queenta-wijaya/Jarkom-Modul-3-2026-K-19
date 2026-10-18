#Nanami & Todo (pastikan hidup lagi setelah soal 18)
#!/bin/sh

service nginx start

#Kusakabe (siapkan IP, internet, dan Apache Benchmark)
#!/bin/sh

ip link set eth0 up
ip addr add 10.73.3.2/24 dev eth0 2>/dev/null
ip route replace default via 10.73.3.1
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8

apk add --no-cache apache2-utils curl

echo "nameserver 10.73.1.2" > /etc/resolv.conf
ab -V | head -2
curl -s -o /dev/null -w "cek web: HTTP %{http_code}\n" http://jujutsu.com/
curl -s http://jujutsu.com/api; echo

#Gojo (Fase A: bersihkan log & cache)
#!/bin/sh

: > /var/log/nginx/access.log
: > /var/log/nginx/error.log
rm -rf /var/cache/nginx/web/*

#Kusakabe (Fase A: benchmark web, cache aktif)
#!/bin/sh

ab -n 600 -c 30 http://jujutsu.com/ > ab_web.txt
grep -E "Complete requests|Failed requests|Non-2xx|Requests per second|Time per request|Connect:|Processing:|Total:" ab_web.txt

#Gojo (Fase A: analisis access log)
#!/bin/sh

echo "=== Status code ==="
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c
echo "=== Total baris access log ==="
wc -l < /var/log/nginx/access.log
echo "=== Ditolak rate limit ==="
grep -c "limiting requests" /var/log/nginx/error.log

#Gojo (Fase B: bersihkan log, rate limit aktif)
#!/bin/sh

: > /var/log/nginx/access.log
: > /var/log/nginx/error.log

#Kusakabe (Fase B: benchmark /api, rate limit aktif)
#!/bin/sh

ab -n 600 -c 30 http://jujutsu.com/api > ab_api_limit.txt
grep -E "Complete requests|Failed requests|Length:|Exceptions:|Non-2xx|Requests per second|Time per request|Connect:|Processing:|Total:" ab_api_limit.txt

#Gojo (Fase B: analisis access log)
#!/bin/sh

echo "=== Status code ==="
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c
echo "=== Total baris access log ==="
wc -l < /var/log/nginx/access.log
echo "=== Ditolak rate limit (429) ==="
grep -c "limiting requests" /var/log/nginx/error.log
echo "=== Error upstream/koneksi ==="
grep -E "connect\(\) failed|upstream timed out|no live upstreams|upstream prematurely" /var/log/nginx/error.log | tail -5

#Gojo (Fase C: matikan rate limit sementara, bersihkan log)
#!/bin/sh

sed -i 's/^\([[:space:]]*\)limit_req zone=api_limit;/\1#limit_req zone=api_limit;/' /etc/nginx/sites-available/gateway
grep -n "limit_req" /etc/nginx/sites-available/gateway
nginx -t && service nginx reload
: > /var/log/nginx/access.log
: > /var/log/nginx/error.log

#Kusakabe (Fase C: benchmark /api baseline)
#!/bin/sh

ab -n 600 -c 30 http://jujutsu.com/api > ab_api_baseline.txt
grep -E "Complete requests|Failed requests|Length:|Exceptions:|Non-2xx|Requests per second|Time per request|Connect:|Processing:|Total:" ab_api_baseline.txt

#Gojo (Fase C: analisis, lalu pulihkan rate limit)
#!/bin/sh

echo "=== Status code ==="
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c
echo "=== Total baris access log ==="
wc -l < /var/log/nginx/access.log
echo "=== Ditolak rate limit ==="
grep -c "limiting requests" /var/log/nginx/error.log
echo "=== Error upstream/koneksi ==="
grep -E "connect\(\) failed|upstream timed out|no live upstreams|upstream prematurely" /var/log/nginx/error.log | tail -5

# Pulihkan rate limit
sed -i 's/^\([[:space:]]*\)#limit_req zone=api_limit;/\1limit_req zone=api_limit;/' /etc/nginx/sites-available/gateway
grep -n "limit_req" /etc/nginx/sites-available/gateway
nginx -t && service nginx reload