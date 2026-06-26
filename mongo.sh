#!/bin/bash
LOG="/var/log/roboshop"
LOG_NAME="$LOG/$0.log"
mkdir -p "$LOG"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
n="\e[0m"

user=$(id -u)
if [ $user -ne 0 ]
then
echo -e "$R not a root user $n" |tee -a "$LOG_NAME"
exit 1;
fi

validate(){

if [ $1 -eq 0 ]
then
echo -e "$G $2 successfully $n" |tee -a "$LOG_NAME"
else
echo -e "$R $2 failed  $n" |tee -a "$LOG_NAME"
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y
validate $? "mongod installed"
systemctl enable mongod
validate $? "enable mongod"
systemctl disable mongod
validate $? "disable mongod"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "updated port"
systemctl restart mongod
validate $? "restarted mongod"

