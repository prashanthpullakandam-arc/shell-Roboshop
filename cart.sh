#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_PATH="/var/log/roboshop"
LOG="$LOG_PATH/$0.log"
CURRENT_LOG=$PWD
Userp=$(id -u)
if [ $USerp -ne 0 ]
then
echo -e "not a super user" |tee -a $LOG
exit 1;
mkdir -p $LOG_PATH
validate (){
if [ $1 -eq 0 ]
then
echo -e "$2 sucessfull" | tee -a $LOG
else
echo -e "$2 failed" |tee -a $LOG
fi
}
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
validate $? "dnf enable"
dnf install nodejs -y
validate $?  "dnf installed"
id roboshop
if [ $? -eq 0 ]
then
echo -e "$Y user already available"
fi
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
mkdir /app 
rm -rf /app/*
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
cd /app 
unzip /tmp/cart.zip
validate $? "file unzipped"
npm install 
cp $PWD/cart.service /etc/systemd/system/cart.service
systemctl daemon-reload
validate $? "Damon reloaded"
systemctl enable cart 
systemctl start cart
