#!/bin/bash

# Create database
echo "Creating database"
/usr/bin/mysqld_safe &
sleep 5
mysql -u root -pa -e "CREATE DATABASE sympa CHARACTER SET utf8;"
mysql -u root -pa -e "GRANT ALL PRIVILEGES ON sympa.* TO sympa@localhost IDENTIFIED BY 'sympa';"
killall mysqld
sleep 1

echo "Starting supervisord"
supervisord -n -c /etc/supervisord.conf
