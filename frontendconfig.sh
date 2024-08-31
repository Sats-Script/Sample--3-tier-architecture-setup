#!/bin/bash

Logfold="/var/log/expense_msg"
scriptname=$(echo "$0" | cut -d "." f1)
time=$(date +%Y-%m-%d-%H-%M)
logfile="$Logfold/$scriptname-$time.log"
mkdir -p $Logfold

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
    echo "$G $2  ... SUCCESS $N"
    else
    echo "$R $2 ......... FAILED $N"
    fi
}

 dnf install nginx &>>$logfile
 validate $? "Nginx installation is"

 systemctl enable nginx &>>$logfile
validate $? "Enable Nginx"

systemctl start nginx &>>$logfile
validate $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? "Downloding frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$logfile
validate $? "Extract frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
validate $? "Copied expense conf"

systemctl restart nginx &>>$logfile
validate $? "Restarted Nginx"
