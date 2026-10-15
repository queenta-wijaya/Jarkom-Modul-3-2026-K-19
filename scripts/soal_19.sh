#Gojo (Gateway: Proxy Cache + Rate Limit)
#!/bin/sh

DOMAIN="jujutsu.com"

mkdir -p /var/cache/nginx/web
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/gateway
cat << 'ENDCONF' > /etc/nginx/sites-available/gateway
proxy_cache_path /var/cache/nginx/web levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=10m use_temp_path=off;

limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

upstream web_cluster {
    server 10.73.4.3;
    server 10.73.4.4;
}

server {
    listen 80 default_server;
    server_name __DOMAIN__ www.__DOMAIN__;

    location / {
        proxy_cache web_cache;
        proxy_cache_valid 200 10m;
        proxy_ignore_headers Cache-Control Expires Set-Cookie;
        add_header X-Cache-Status $upstream_cache_status always;

        proxy_pass http://web_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location /api {
        limit_req zone=api_limit;
        limit_req_status 429;

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
cat /etc/nginx/sites-available/gateway

#Gojo (Kosongkan cache sebelum uji)
#!/bin/sh

rm -rf /var/cache/nginx/web/*

#Itadori (Uji cache: MISS lalu HIT)
#!/bin/sh

echo "nameserver 10.73.1.2" > /etc/resolv.conf

for i in 1 2 3 4; do
  curl -s -D - -o /dev/null http://jujutsu.com/ | grep -i "X-Cache-Status"
done

#Itadori (Uji rate limit: 30 request beruntun ke /api)
#!/bin/sh

for i in $(seq 1 30); do curl -s -o /dev/null -w "%{http_code}\n" http://jujutsu.com/api; done | sort | uniq -c

#Gojo (Bukti log rate limit)
#!/bin/sh

grep "limiting requests" /var/log/nginx/error.log | tail -5