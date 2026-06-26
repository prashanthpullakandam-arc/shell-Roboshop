#!/bin/bash

user=$(id -u)
if [ $user -ne 0 ]
then
echo "not a root user"
return 1;
fi