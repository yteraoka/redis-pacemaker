#!/bin/bash

yum -y install epel-release
yum -y install redis pcs pacemaker

systemctl start firewalld
systemctl enable firewalld
firewall-cmd --add-service high-availability
firewall-cmd --add-service high-availability --permanent
firewall-cmd --add-port 6379/tcp --permanent
firewall-cmd --add-port 6379/tcp

systemctl start pcsd
systemctl enable pcsd

echo passwd | passwd hacluster --stdin

sed -i '/redis/d' /etc/hosts
cat >> /etc/hosts <<EOF
192.168.33.10 redis
192.168.33.11 redis1
192.168.33.12 redis2
192.168.33.20 client
EOF

echo 'vm.overcommit_memory = 1' > /etc/sysctl.d/redis.conf
echo 'net.core.somaxconn = 1024' >> /etc/sysctl.d/redis.conf
sysctl -p

# disable transparent hugepage
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
chmod 755 /etc/rc.d/rc.local

cat > /etc/security/limits.d/30-redis.conf <<EOF
redis soft nofile 10240
redis hard nofile 10240
EOF

cat > /etc/redis.conf <<EOF
bind 0.0.0.0
port 6379
logfile /var/log/redis/redis.log
pidfile /var/run/redis-server.pid
dir /var/lib/redis
unixsocket /var/lib/redis/redis.sock
dbfilename dump.rdb
requirepass password
masterauth password
maxmemory 33554432
maxclients 100
maxmemory-policy volatile-lru
loglevel notice
EOF
