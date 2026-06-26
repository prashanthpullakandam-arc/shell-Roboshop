#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
n="\e[0m"

LOG="/var/log/shellscript"
LOG_PATH="$LOG/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.ananthsolutions.online"



user=$(id -u)

if [ $user -ne 0 ]
then
echo -e "$R not a root user $n";
exit 1;
fi
mkdir -p $LOG_PATH
validate(){
if [ $1 -eq 0 ]
then
echo -e "$G $2 successfully$n" |tee -a $LOG_PATH
else
echo -e "$R $2 Failed $n" |tee -a $LOG_PATH
fi
}
dnf module disable nodejs -y
validate $? "nodejs disabled"
dnf module enable nodejs:20 -y
validate $? "node js enabled"
dnf install nodejs -y
validate $? "node js installed"

id -roboshop &>>$LOG_PATH
if[ $? -eq 0 ] 
then
echo -e "$Y user already available $n" &>>$LOG_PATH
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "user created"
mkdir -p /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "downloaded data"
rm -rf /app
validate $? "removed data from temp"
cd /app
unzip /tmp/catalogue.zip
validate $? "unzipped data from temp"
npm install 
validate $? "npm installed"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
validate $? "file moved"
systemctl daemon-reload
validate $? "daemon-reloaded"
systemctl enable catalogue
validate $? "enable nodejs"
systemctl start catalogue
validate $? "start nodejs"
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copied script"
dnf install mongodb-mongosh -y
validate $? "mongodb installed "
INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi
systemctl restart catalogue
VALIDATE $? "Restarting catalogue"

