#Yaga (DB Master)
#!/bin/sh

DB="db_shibuya_jujutsu"

# 1. Jalur ke Jichi & DNS (supaya apt-get bisa jalan)
ip route add default via 10.73.4.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install MariaDB (ini yang membuat user mysql ada)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mariadb-server mariadb-client

# 3. Konfigurasi Master (server-id, binary log, bind-address)
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql

cat << EOF > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
bind-address            = 0.0.0.0

server-id               = 1
log_bin                 = /var/log/mysql/mysql-bin.log
binlog_do_db            = $DB
EOF

# 4. Restart service supaya server-id & log_bin aktif
service mariadb restart || service mariadb start
sleep 3
mysql -u root -e "SELECT @@server_id, @@log_bin;"

# 5. Buat Database, Tabel, User Replikasi & User Remote Network 4
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS $DB;
USE $DB;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    activity VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'password123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER IF NOT EXISTS 'admin_net4'@'10.73.4.%' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON $DB.* TO 'admin_net4'@'10.73.4.%';
GRANT SELECT, SHOW VIEW, TRIGGER, EVENT, LOCK TABLES, RELOAD, BINLOG MONITOR ON *.* TO 'admin_net4'@'10.73.4.%';
FLUSH PRIVILEGES;
EOF

# 6. Tampilkan status master (SS soal 13)
mysql -u root -e "SHOW MASTER STATUS;"
mysql -u root -e "SELECT user,host FROM mysql.user WHERE user IN ('repl','admin_net4');"
ss -tlnp | grep 3306

#Inumaki (DB Slave)
#!/bin/sh

DB="db_shibuya_jujutsu"

# 1. Jalur ke Jichi & DNS (supaya apt-get bisa jalan)
ip route add default via 10.73.4.1 2>/dev/null
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 2 8.8.8.8 || { echo "GAGAL: tidak ada internet, cek script Jichi"; exit 1; }

# 2. Install MariaDB
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mariadb-server mariadb-client

# 3. Konfigurasi Slave (server-id=2)
printf "[mysqld]\nserver-id = 2\n" > /etc/mysql/mariadb.conf.d/99-slave.cnf

# 4. Restart service supaya server-id aktif
service mariadb restart || service mariadb start
sleep 3
mysql -u root -e "SELECT @@server_id;"

# 5. Uji akses remote Network 4 ke Yaga (user admin_net4)
mysql -h 10.73.4.9 -u admin_net4 -ppassword123 -e "SELECT USER(), CURRENT_USER();" || { echo "GAGAL: tidak bisa login ke Yaga, jalankan script Yaga dulu"; exit 1; }

# 6. Ambil dump + posisi binlog langsung dari Yaga
mysqldump -h 10.73.4.9 -u admin_net4 -ppassword123 --databases $DB --single-transaction --master-data=2 > /tmp/dump.sql
[ -s /tmp/dump.sql ] || { echo "GAGAL: dump kosong"; exit 1; }

# 7. Reset slave lama & import dump
mysql -u root -e "STOP SLAVE; RESET SLAVE ALL;"
mysql -u root < /tmp/dump.sql

# 8. Ambil nama file & posisi binlog otomatis dari dump
LOG_FILE=$(grep -o "MASTER_LOG_FILE='[^']*'" /tmp/dump.sql | cut -d"'" -f2)
LOG_POS=$(grep -o "MASTER_LOG_POS=[0-9]*" /tmp/dump.sql | cut -d= -f2)
echo "Master File: $LOG_FILE | Position: $LOG_POS"

# 9. Hubungkan Slave ke Master (Yaga) & start replikasi
mysql -u root << EOF
CHANGE MASTER TO
  MASTER_HOST='10.73.4.9',
  MASTER_USER='repl',
  MASTER_PASSWORD='password123',
  MASTER_LOG_FILE='$LOG_FILE',
  MASTER_LOG_POS=$LOG_POS;
START SLAVE;
EOF

# 10. Tampilkan status slave (SS soal 13: IO & SQL Running harus Yes)
sleep 2
mysql -u root -e "SHOW SLAVE STATUS\G" | grep -E "Master_Host|Master_Log_File|Slave_IO_Running|Slave_SQL_Running|Error"

#Demo Pembuktian (Yaga insert -> Inumaki select)
#!/bin/sh

DB="db_shibuya_jujutsu"

# [Di Yaga] 1. Insert data baru ke Master
mysql -u root -e "USE $DB; INSERT INTO request_logs (activity) VALUES ('TEST REPLIKASI OK');"

# [Di Yaga] 2. Lihat data di Master
mysql -u root -e "USE $DB; SELECT * FROM request_logs;"

# [Di Inumaki] 3. Data harus muncul otomatis di Slave
mysql -u root -e "USE $DB; SELECT * FROM request_logs;"