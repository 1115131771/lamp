#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    function.sh
# Revision:    1.0
# Date:        2014/11/30
# Author:      shuiqingliu
# Email:       shuiqingliu14#gmail.com
# Website:     www.shuiqingliu.com
# Description: def function for install LAMP
# -------------------------------------------------------------------------------


#message
info_msg(){
    showmsg=$1
    shift && printf "\033[1;32m${showmsg}\033[0m" "$@"
}

error_msg(){
    warnmsg=$1
    shift && printf "\033[1;33m[WARN] ${warnmsg}\033[0m" "$@"
}

#check installed
check_installed(){
    if [ -d /usr/local/php ]; then
        #
        error_msg "LAMP already installed\n"
        printf "continue install please input y or input n exit:"
        read isno
        if [ "X$isno" = "Xy" ]; then
            #statementsd
            if [ -d /tmp/lamp ]; then
                #statements
                cd /tmp/lamp/php-$php_54_ver
                make uninstall
                rm -rf /usr/local/php
                cd ..
                 rm -rf ~/tmp/lamp
            else
                rm -rf /usr/local/php
            fi
        else
            exit 1
        fi
    fi
}


#auto install confirm
confirm(){
    get_char(){
        savestty=`stty -g`
        #close output
        stty -echo
        #open quick response mode
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        #allow standard input mode
        stty -raw
        stty echo
        stty $savestty
    }
    echo ""
    info_msg "LAMP will install PHP(5.4.34),phpmyadmin(4.0.10.5)\n"
    info_msg "Press any key to start installation or CTRL+C to cancel.\n"
    char=`get_char`
}

#Synchronize the system clock to Network Time 
sync_time(){
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    yum install -y ntp
    ntpdate -d cn.pool.ntp.org
    date
}

init(){
    password_i="0"  
    while [ $password_i != "1" ]
    do  
    #set up password
    password="admin123"
        info_msg "Please input MySQL password(AT LEAST 6 CHARACTERS!!!!!):\n"
        printf "(Default password: admin123):" 
        read password
        echo ""
        if [ "$password" = "" ]; then
            password="admin123"
        fi
        echo "========================================================================="
        echo password="$password"
        echo "========================================================================="
    password_i="1"
    #check length of password
    string=${#password}
        if [ "$string" -lt "6" ]; then
            echo "AT LEAST 6 CHARACTERS!!!!PLEASE RUN THE SCRIPT AGAIN!!!"
            password_i="0"
        fi
    done
}

install_package(){
    #disable selinux
    setenforce 0 
    #check and remove old package
    rpm -qa|grep  httpd
    rpm -e httpd
    rpm -qa|grep mysql
    rpm -e mysql
    rpm -qa|grep php
    rpm -e php
    yum -y remove httpd* mysql* php*
    #get system version
    cetosversion=$(cat /etc/redhat-release | grep -o [0-9] | sed 1q)
    if [ "$cetosversion" = "5" ]; then
        rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm
    else
        rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    fi

    #update system
    yum -y update

    #get bit
    bit=$(getconf LONG_BIT)
    if [ $bit = "64" ]; then
        #install base package
        yum -y install glibc flex re2c bison gcc automake openssl-devel mhash-devel expect ruby autoconf213 libtool gcc-c++ libjpeg-devel libpng-devel libxml2-devel curl curl-devel libmcrypt-devel freetype-devel patch make zlib-devel libtool-ltdl-devel
    else
        yum -y install flex re2c bison gcc automake openssl-devel mhash-devel expect ruby autoconf213 libtool gcc-c++ libjpeg-devel libpng-devel libxml2-devel curl curl-devel libmcrypt-devel freetype-devel patch make zlib-devel libtool-ltdl-devel
    fi
}

#build apache,the future maybe compiled from source 
build_apache(){
    yum -y install httpd httpd-devel
    rm -rf /etc/httpd/conf/httpd.conf
    wget -N $httpd_conf_source
    mv -f $httpd_conf /etc/httpd/conf/
    /etc/init.d/httpd start
    chkconfig --level 34 httpd on
}

#build mysql.the future maybe compiled from source
build_mysql(){
    yum -y install mysql-server mysql-devel
    #disable old_password
    sed -i "s/old_passwords=1/old_passwords=0/g" /etc/my.cnf
    #mysql setting
    /etc/init.d/mysqld start
    mysqladmin -u root password $password
    mysql_version=$(mysql -V | awk '{ print $5 }' | awk -F "." '{print $1"."$2}')
    /etc/init.d/mysqld restart
    chkconfig --level 345 mysqld on
}

build_php(){
    mkdir /tmp/lamp 
    cd /tmp/lamp
    #download pachage
    wget -c $php_54_source
    wget -c $php_54_mail_header_patch_source
    tar zxf $php_54
    cd /tmp/lamp/php-$php_54_ver
    #apply patch
    patch -p1 < /tmp/lamp/$php_54_mail_header_patch
    #check autoconf
    ./buildconf --force

    #config
    bit=$(getconf LONG_BIT)
    if [ "$bit" = "64" ]; then
        #statements
        ./configure '--prefix=/usr/local/php' '--with-apxs2=/usr/sbin/apxs' '--with-libdir=lib64' '--with-pdo-mysql' '--with-mysql' '--with-mysqli' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-mbstring' '--with-iconv' '--enable-inline-optimization' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--enable-bcmath'
    else
        ./configure '--prefix=/usr/local/php' '--with-apxs2=/usr/sbin/apxs' '--with-pdo-mysql' '--with-mysql' '--with-mysqli' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm'  '--enable-mbstring' '--with-iconv' '--enable-inline-optimization' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--enable-bcmath'    
    fi

    #start make
    info_msg $(date)\n
    make 
    make install

    cp ./php.ini-development /usr/local/php/lib/php.ini
    sed -i '/extension_dir/d' /usr/local/php/lib/php.ini
    sed -i '/sendmail_path/d' /usr/local/php/lib/php.ini
    sed -i '/smtp_port/a\sendmail_path = \/usr\/sbin\/sendmail -t\n' /usr/local/php/lib/php.ini
}


phpinfo()
{
#Download phpinfo
cd /tmp/lamp
wget $phpinfo_source
tar zxf $phpinfo
rm -f /var/www/html/index.html
rm -f /var/www/html/phpinfo.php
mv -f $phpinfo_dir/* /var/www/html/
}


#build phpmyadmin
phpmyadmin(){
#Download phpmyadmin
    mkdir /tmp/phpmyadmin
    cd /tmp/phpmyadmin
    wget $phpmyadmin_source
    tar zxf $phpmyadmin
    mkdir /var/www/html/phpmyadmin
    mv -f $phpmyadmin_dir/* /var/www/html/phpmyadmin
}

#restart httpd
restart_httpd(){
    /etc/init.d/httpd stop
    /etc/init.d/httpd start
}

#check lamp installed
check_lamp_installed(){
    info_msg "=================================================================\n"
    info_msg "Final Checking.....\n"
    if [ -f /usr/sbin/httpd ]; then
        #found httpd
        info_msg "Apache [found]\n"
    else
        error_msg "Apache [not found]\n"
    fi

    if [ -f /usr/local/php/bin/php ]; then
        #found
        info_msg "PHP [found]\n"
    else
        error_msg "PHP [not found]\n"
    fi

    if [ -f /usr/bin/mysql ];then
        info_msg "MySQL [found]\n"
    else
        info_msg "MySQL [not found]\n"
    fi
    info_msg "===================================================================\n"
}


lamp_tool()
{
cd /tmp/lamp
wget $centostools_source
tar zxf $centostools
mv $centostools_dir/* /root/lamp/
}


finish(){
    info_msg "=================================================================\n"
    info_msg "LAMP has been set up.\n"
    info_msg "Please use command "ifconfig" to found your ip and visit it.\n"
    info_msg "=================================================================\n"
    info_msg "For more information ,please visit our Website http://www.laozuo.org\n"
    info_msg "=================================================================\n"
    info_msg "BYE~~~\n"
}

installed_file()
{
echo "LAMP 1.0 CentOS" >> /root/lamp/.installed
}