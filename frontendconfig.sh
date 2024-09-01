# #!/bin/bash

# Logfold="/var/log/expense_msg"
# scriptname=$(echo "$0" | cut -d "." -f1)
# time=$(date +%Y-%m-%d-%H-%M)
# logfile="$Logfold/$scriptname-$time.log"
# mkdir -p $Logfold

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
#     echo -e "$R $2  ... FAILED $N"
#     else
#     echo -e  "$G $2 ......... SUCCESS $N"
#     fi
# }

#  dnf install nginx -y
#  validate $? "Nginx installation is"

#  systemctl start nginx &>>$logfile
# validate $? "start Nginx"

# systemctl enable nginx &>>$logfile
# validate $? "Enable Nginx

# rm -rf /usr/share/nginx/html/* &>>$logfile
# validate $? "Removing default website"

# curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
# validate $? "Downloding frontend code"

# cd /usr/share/nginx/html
# unzip /tmp/frontend.zip &>>$logfile
# validate $? "Extract frontend code"

# cp /home/ec2-user/Sample--3-tier-architecture-setup/expense.conf /etc/nginx/default.d/expense.conf
# validate $? "Copied expense conf"

# systemctl restart nginx &>>$logfile
# validate $? "Restarted Nginx"

#!/bin/bash

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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloding frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract frontend code"

cp /home/ec2-user/Sample--3-tier-architecture-setup/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted Nginx"