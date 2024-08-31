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

 dnf module disable nodejs:18 -y &>> $logfile

 dnf module enable nodejs:20 -y &>> $logfile
 validate $? "Nodejs ver20 enabling is"

 dnf install nodejs -y &>> $logfile
 validate $? "Nodejs installation is"

 id expense &>>$logfile
 if [ $? -ne 0 ]
 then
 echo -e "$Y Creating app user ; name is expense $N"
 validate $? "User creation is"
 else
 echo -e "$Y Downloading Expense App code is ready $N"

 mkdir -p app
 curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
 validate $? "Downloading Expense app code is"
 cd /app
 rm -rf /app/*
 unzip /tmp/backend.zip

 npm install &>>$logfile
 cp /home/ec2-user/expense-shell/backend.service  /etc/systemd/system/backend.service

 dnf install mysql -y &>>$logfile
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.daws81s.online -uroot -pExpense@1 < /app/schema/backend.sql &>>$logfile
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$logfile
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$logfile
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$logfile
VALIDATE $? "Restarted Backend"

