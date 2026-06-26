#!/bin/bash
securityid="sg-084020e387d413aac"
AmiId="ami-0220d79f3f480ecf5"

for Instance in $@
do
instanceid=$(aws ec2 run-instances \
    --image-id $AmiId \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $securityid \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instance}]" \
	--query "Instances[0].InstanceId" \
    --output text)

if [ $Instance = 'Frontend' ]
then
IP=$(aws ec2 describe-instances \
    --instance-ids $instanceid \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text)
    echo "$IP"
else
IP=$(aws ec2 describe-instances \
    --instance-ids $instanceid \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text)
    echo "$IP"
fi
done 
