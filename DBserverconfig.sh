#!/bin/bash

Logfol="var/log/expenseapp-msgs"
scriptname=$(echo "$0" | cut -d "." f1)
time=$(date +%Y-%m-%d-%H-%M)
logfile="$Logfol/$scriptname-$time.log"
mkdir -p $Logfol

Uid=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $Uid -ne 0 ]
then
 echo -e "$R please run script as root user$N"
 else
 echo -e "$G Script is running as root user now $N" |tee -a $logfile
 fi

validate(){
    if [ $1 -ne 0 ]
    then
    echo -e "$G $2  ... SUCCESS $N"
    else
    echo  -e "$R $2 ......... FAILED $N"
    fi
}

dnf install mysql-server -y &>>$logfile
validate $? "mysql-server installation is"

systemctl start mysqld &>>$logfile
validate $? "Begining Mysqlserver is"

systemctl enable mysqld &>>$logfile
validate $? "Enabling MYSQL is "

mysql -h mysql.heyitsmine.store -u root -pExpense@1 -e 'show databases' &>>$logfile
if [ $? -ne 0 ]
then
echo -e "$Y setting up Mysql root password $N"
mysql_secure_installation --set-root-pass Expense@1 &>>$logfile
validate    $?  "Setting up root password is"
else
echo -e "$Y DBroot server is protected with a password $N"
fi




