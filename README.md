# Redis HA using pacemaker

* Vagrant
* CentOS 7
* Pacemaker
  * `ocf:heartbeat:redis`
  * `ocf:heartbeat:IPaddr2`

```
vagrant up
vagrant ssh redis1
bash /vagrant/init.sh
```
