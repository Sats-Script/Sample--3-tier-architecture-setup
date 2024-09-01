# #!/bin/bash

# Logfol="var/log/expenseapp-msgs"
# scriptname=$(echo "$0" | cut -d "." -f1)
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

#  validate(){
#     if [ $1 -ne 0 ]
#     then
#     echo -e "$R $2  ... FAILED $N"
#     else
#     echo  -e "$G $2 ......... SUCCESS $N"
#     fi
# }

#  dnf module disable nodejs:18 -y &>> $logfile

#  dnf module enable nodejs:20 -y &>> $logfile
#  validate $? "Nodejs ver20 enabling is"

#  dnf install nodejs -y &>> $logfile
#  validate $? "Nodejs installation is"

#  id expense &>>$logfile
#  if [ $? -ne 0 ]
#  then
#  echo -e "$Y Creating app user ; name is expense $N"
#  validate $? "User creation is"
#  else
#  echo -e "$Y Downloading Expense App code is ready $N"
# fi

#  mkdir -p /app
#  curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
#  validate $? "Downloading Expense app code is"
#  cd app/
#  rm -rf /app/*
#  unzip /tmp/backend.zip

#  npm install &>>$logfile
#  cp /home/ec2-user/Sample--3-tier-architecture-setup/backend.service  /etc/systemd/system/backend.service

#  dnf install mysql -y &>>$logfile
# validate $? "Installing MySQL Client"

# mysql -h mysql.heyitsmine.store -u root -pExpense@1 < /app/schema/backend.sql &>>$logfile
# validate $? "Schema loading"

# systemctl daemon-reload &>>$logfile
# validate $? "Daemon reload"

# systemctl enable backend &>>$logfile
# validate $? "Enabled backend"

# systemctl restart backend &>>$logfile
# validate $? "Restarted Backend"

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"

npm install &>>$LOG_FILE
cp /home/ec2-user/Sample--3-tier-architecture-setup/backend.service  /etc/systemd/system/backend.service

# load the data before running backend

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.heyitsmine.store -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarted Backend"

