#!/bin/bash

# Logfol="var/log/expenseapp-msgs"
# scriptname=$(echo "$0" | cut -d "." f1)
# time=$(date +%Y-%m-%d-%H-%M)
# logfile="$Logfol/$scriptname-$time.log"
# mkdir -p $Logfol

# Uid=$(id -u)
# R="\e[31m"
# G="\e[32m"
# N="\e[0m"
# Y="\e[33m"

# if [ $Uid -ne 0 ]
# then
#  echo -e "$R please run script as root user$N"
#  else
#  echo -e "$G Script is running as root user now $N" |tee -a $logfile
#  fi

# validate(){
#     if [ $1 -ne 0 ]
#     then
#     echo -e "$G $2  ... SUCCESS $N"
#     else
#     echo  -e "$R $2 ......... FAILED $N"
#     fi
# }

# dnf install mysql-server -y  &>>$logfile
# validate $? "mysql-server installation is"

# systemctl start mysqld &>>$logfile
# validate $? "Begining Mysqlserver is"

# systemctl enable mysqld &>>$logfile
# validate $? "Enabling MYSQL is "

# mysql -h mysql.heyitsmine.store -u root -pExpense@1 -e 'show databases' &>>$logfile
# if [ $? -ne 0 ]
# then
# echo -e "$Y setting up Mysql root password $N"
# mysql_secure_installation --set-root-pass Expense@1 &>>$logfile
# validate    $?  "Setting up root password is"
# else
# echo -e "$Y DBroot server is protected with a password $N"
# fi

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root priveleges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MySQL Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started MySQL server"

mysql -h mysql.daws81s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi


