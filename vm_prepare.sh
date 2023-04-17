#!/bin/bash
yum install epel-release -y
yum install nginx mailx -y
systemctl --now enable nginx
echo "0 * * * * root /vagrant/script.sh | mail -s 'Логирование NGINX' root@localhost" >> /etc/crontab
systemctl reload crond
curl http://localhost > /dev/null
curl http://localhost/test.php > /dev/null