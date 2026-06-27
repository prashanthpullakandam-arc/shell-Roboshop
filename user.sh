#!/bin/bash
LOG_PATH="/var/log/shellscript"
LOG="$LOG_PATH/$0.log"
Directory=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
user=$(id -u)
if [ $user -ne 0 ]
then
echo -e "$R not a root user $N"
exit 1;
fi
mkdir -p $LOG_PATH
validate(){
if [ $1 -eq 0 ]
then
echo -e "$G $2 successfull$N" | tee -a $LOG
else
echo -e "$R $2 failure $N" |tee -a $LOG
fi
}
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
validate $? "dnf module enabled"
dnf install nodejs -y
validate $? "dnf module deployed"
id roboshop
if [ $? -eq 0 ]
then
echo -e "$Y User already available$N"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "user created"
fi
mkdir -p /app
rm -rf /app/*
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
cd /app 
unzip /tmp/user.zip
validate $? "files unzipped"
npm install
validate $? "installed depenceies"
cp $Directory/user.service /etc/systemd/system
validate $? "file copied"
systemctl daemon-reload
validate $? "daemon reloaded"
systemctl enable user
systemctl start user
validate $? "user started"

