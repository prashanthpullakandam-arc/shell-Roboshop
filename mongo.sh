#!/bin/bash

id -u
if [ $? -ne 0]
then
echo "not a root user"
return 1;
fi