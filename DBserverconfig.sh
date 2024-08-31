#!/bin/bash

Uid=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


# read pkg
# pack1=mysql
# pack2=nodejs
# pack3=nginx

# if [ "$pkg" = "$pack1" ]
# then 
# echo -e "$G $pkg Installing $N"
# else
# if test "$pkg" = "$pack2"
# then
# echo  -e "$G $pkg Installing $N"
# else
# if [[ "$pkg" == "$pack3" ]]
# then
# echo  -e "$G $pkg Installing $N"
# else
# echo -e "$R This Script wont work for entered package $N"
# fi
# fi
# fi



validate(){
    if [ $1 -ne 0 ]
    then
    echo "$G $2  ... SUCCESS $N"
    else
    echo "$R $2 ......... FAILED $N"
    fi
}

check(){
dnf list installed mysql-server &>> null.txt
validate $? "mysql-server is not installed"

dnf install mysql-server -y
validate $? "mysql-server"
systemctl start mysqld
systemctl enable mysqld
mkdir -p /app
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading Expense application code"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"

mysql -h mysql.heyitsmine.store -uroot < /app/schema/backend.sql &>>$LOG_FILE 
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarted Backend"

}

if [ $Uid -ne 0 ] 
then
echo -e " $R Please run script as Sudo user ; $Y current userid is :$Uid "
exit 1
else
echo -e " $G Script is running now as sudo user  $N " 
check 
fi
