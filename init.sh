#!/bin/bash

set -e

sudo pcs cluster auth redis1 redis2 -u hacluster -p passwd
sudo pcs cluster setup --start --name redis redis1 redis2
sudo pcs node standby redis2

sudo pcs cluster cib > cib.xml
pcs -f cib.xml resource defaults resource-stickiness="INFINITY"
pcs -f cib.xml resource defaults migration-threshold=1
pcs -f cib.xml property set no-quorum-policy="ignore"
pcs -f cib.xml property set stonith-enabled="false"
pcs -f cib.xml resource create master-vip ocf:heartbeat:IPaddr2 \
  ip=192.168.33.10 cidr_netmask=24 nic=eth1 iflabel=master \
  op monitor interval=3s
pcs -f cib.xml resource create redis ocf:heartbeat:redis \
  op start timeout="300s" \
  op monitor interval="5s" \
  op monitor interval="3s" role="Master" \
  master
pcs -f cib.xml constraint colocation add master-vip with master redis-master score=INFINITY
#pcs -f cib.xml resource create monitor ocf:pacemaker:ClusterMon \
#  user="root" extra_options="--external-agent=/some/where/notify.sh" \
#  meta migration-threshold="INFINITY" --clone
sudo pcs cluster cib-push cib.xml

set +e

i=0
while : ; do
    i=$(($i + 1))
    started=$(sudo pcs status | grep master-vip | grep -c "Started redis1")
    echo -n "."
    if [ "$started" = "1" ] ; then
        echo
        break
    fi
    if [ $i -gt 60 ] ; then
        echo "couldn't get started"
        sudo pcs status
        exit 1
    fi
    sleep 1
done

sudo pcs node unstandby redis2

i=0
while : ; do
    i=$(($i + 1))
    echo -n "."
    role=$(redis-cli -a password -h redis2 info 2> /dev/null | grep ^role: | sed 's/\r//')
    if [ "$role" = "role:slave" ] ; then
        echo
        break
    fi
    if [ $i -gt 300 ] ; then
        echo "can't connect redis2"
        exit 1
    fi
    sleep 1
done

sudo pcs status
echo

echo "[redis1]"
redis-cli -a password -h redis1 info replication

echo

echo "[redis2]"
redis-cli -a password -h redis2 info replication
