#!/bin/bash

id -user
if [ $? -ne 0]
then
echo "not a root user"
return 1;
fi