#!/bin/bash
securityid="sg-084020e387d413aac"
AmiId="ami-0220d79f3f480ecf5"
Hostzone="Z0529426UUSGOVH6OLOK"
DomainName="ananthsolutions.online"

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
    RecordName=$DomainName
    
else
IP=$(aws ec2 describe-instances \
    --instance-ids $instanceid \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text)
    echo "$IP"
   RecordName="$Instance.$DomainName"

fi
aws route53 change-resource-record-sets \
  --hosted-zone-id $Hostzone \
  --change-batch '{
    "Changes": [
      {
        "Action": "CREATE",
        "ResourceRecordSet": {
          "Name": "'$RecordName'",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [{"Value": "'$IP'"}]
        }
      }
    ]
  }'
done 
 