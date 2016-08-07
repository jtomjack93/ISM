#!/bin/bash

echo "172.23.135.68 intelligentsm.net" >> /etc/hosts
cp ./* ../

adduser nick
usermod -G sudo,www-data nick

adduser tom
usermod -G sudo,www-data tom

adduser adrian
usermod -G sudo,www-data adrian

wget https://intelligentsm.net/html.tar.gz
wget https://intelligentsm.net/mysql.sql
wget https://intelligentsm.net/phpmyadmin.sql
wget https://intelligentsm.net/wordpress.sql
wget https://intelligentsm.net/intelligentsmCA.crt
wget https://intelligentsm.net/intelligentsm.crt
wget https://intelligentsm.net/intelligentsm.key
wget https://intelligentsm.net/intermediate.crt
wget https://intelligentsm.net/apache2.tar.gz
wget https://intelligentsm.net/postfix.tar.gz
wget https://intelligentsm.net/ism.tar.gz
wget https://intelligentsm.net/git.tar.gz
wget https://intelligentsm.net/wpconfig.php

a2enmod ssl

mkdir /usr/local/ssl
mv intelligentsmCA.crt /usr/local/ssl/
mv intelligentsm.crt /usr/local/ssl/
mv intelligentsm.key /usr/local/ssl/
mv intermediate.crt /usr/local/ssl/

apt-get -y update && apt-get -y upgrade
apt-get -y install wordpress
apt-get -y install phpmyadmin
apt-get -y install php5-mcrypt
apt-get -y install ghostscript
apt-get -y install unzip
apt-get -y install fail2ban
apt-get -y install postfix
apt-get -y install git
postmap /etc/postfix/virtual
mv -i /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/
php5enmod mcrypt

mysql -u root -p'america!1' -e "CREATE DATABASE phpmyadmin;"
mysql -u root -p'america!1' -e "CREATE DATABASE wordpress;"

mysql -u root -p'america!1' mysql < mysql.sql
mysql -u root -p'america!1' phpmyadmin < phpmyadmin.sql
mysql -u root -p'america!1' wordpress < wordpress.sql

tar -zxvf html.tar.gz
tar -zxvf apache2.tar.gz
tar -zxvf postfix.tar.gz
tar -zxvf ism.tar.gz
tar -zxvf git.tar.gz
rm -r /var/www/html
mv var/www/html /var/www/
mv wp-config.php /var/www/
rm -r /etc/apache2
mv etc/apache2 /etc/
rm -r /etc/postfix
mv etc/postfix /etc/
mv opt/ism /opt/ism
mv opt/ansur/asign/asign-online/.git /opt/ansur/asign/asign-online/.git


./asign-server-5.1-ubuntu-14.04-x86_64.sh

wget https://github.com/interconnectit/Search-Replace-DB/archive/master.zip
unzip master.zip
cp Search-Replace-DB-master/srdb.cli.php /usr/local/bin/frep
cp Search-Replace-DB-master/srdb.class.php /usr/local/bin/
chmod 644 /usr/local/bin/frep
chmod +x /usr/local/bin/frep
echo "Enter full new domain name: "
read domain
echo "Enter asign domain name: "
read asignDomain
frep -h localhost -n wordpress -u root -p'america!1' -s intelligentsm.net -r $domain
frep -h localhost -n wordpress -u root -p'america!1' -s 'asign.'$domain -r $asignDomain

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
sed -i.old -r '/define\S\S[A-Z]{4}[A-Z]?[A-Z]?_([A-Z]{4})?([A-Z]{2})?_?(KEY|SALT)/d' /var/www/wp-config.php
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

sed -i -e 's/intelligentsm.net/'$domain'/g' /var/www/wp-config.php
sed -i -e 's/intelligentsm.net/'$domain'/g' /etc/apache2/sites-available/000-default.conf
sed -i -e 's/intelligentsm.net/'$asignDomain'/g' /etc/apache2/sites-available/asign.conf
sed -i -e 's/intelligentsm.net/'$domain'/g' /etc/postfix/main.cf

chown -R www-data:www-data /var/www
chmod -R g+w /var/www

echo "*/5 * * * * /opt/ism/dbsync.sh" >> /var/spool/cron/crontabs/root

#a2ensite 000-default.conf
#a2ensite asign.conf

rm -rf ./*

reboot
