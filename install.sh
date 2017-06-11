#!/bin/bash
mkdir /root/lamp
sh centos.sh $1 | tee install.log
cp install.log /root/lamp/install.log
sed -i 's/$/<\br\>/g' install.log
cp install.log /var/www/html/installlog.html
