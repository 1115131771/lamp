#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    centos.sh
# Revision:    1.0
# Date:        2014/11/30
# Author:      shuiqingliu
# Email:       shuiqingliu14#gmail.com
# Website:     www.shuiqingliu.com
# Description: loda function to complete install
# -------------------------------------------------------------------------------


#def color
CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

clear
echo -e $CL_BLU$(date)$CL_RST

#sto our information
echo -e $CL_CYN"========================================================================="$CL_RST
echo -e $CL_MAG"LAMP V1.0 for CentOS/RedHat Linux Written by www.laozuo.org"$CL_RST
echo -e $CL_CYN"========================================================================="$CL_RST
echo -e $CL_MAG"A tool to auto-compile & install APACHE+MySQL+PHP on Linux "$CL_RST
echo -e ""
echo -e $CL_MAG"For more information please visit http://www.yumlamp.com/"$CL_RST
echo -e $CL_CYN"========================================================================="$CL_RST

#check root user
if [ $(id -u) != "0" ]; then
	echo -e $CL_RED"Error: You must be root to run this script, please login as root to install LAMP"$CL_RST
	exit 1
fi

#load source
if [ -f ./sources ]; then
	source ./sources 2>/dev/null
else
	wget http://down.llsmp.cn/lamp/sources
	source ./sources 2>/dev/null
fi

#check load complete
if [ $? != 0 ]; then
	echo -e $CL_RED"Error Can not include sources.Please confirm this file exist!"$CL_RST
	exit 1
fi

#load function
source ./function.sh 2>/dev/null
if [ $? != 0 ]; then
	#statements
	. ./function.sh 2>/dev/null
	if [ $? != 0 ]; then
		#statements
		echo -e $CL_YLW[ERROR] Can not include 'functions.sh'.$CL_RST
		exit 1
	fi
fi

check_installed
init
confirm
sync_time
install_package
build_apache
build_mysql
build_php
phpinfo
phpmyadmin
restart_httpd
check_lamp_installed
lamp_tool
finish
installed_file
