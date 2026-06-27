#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_PATH="/var/log/roboshop"
LOG="$LOG_PATH/$0.log"

user=$(id -u)
if [ $user -ne 0 ]
then
echo  -e "$R not a root user $N"
exit 1;
fi

mkdir -p $LOG_PATH

validate(){
if [ $1 -eq 0 ]
then
echo -e "$G $2 successful$N" | tee -a $LOG
else
echo -e "$R $2 failed $N" | tee -a $LOG
fi
}
dnf module disable redis -y
dnf module enable redis:7 -y
validate $? "redis 7 enabled"
dnf install redis -y
validate ? "redis installed"

sed -i -e '/s/127.0.0.1/0.0.0.0/' -e '/protected-mode/c\protected-mode no' /etc/redis/redis.conf
validate ? "edited the redis config"
systemctl enable redis
systemctl start redis
validate ? "redis started"
