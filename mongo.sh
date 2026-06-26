#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
n="\e[0m"

user=$(id -u)
if [ $user -ne 0 ]
then
echo -e "$R not a root user $n"
exit 1;
fi