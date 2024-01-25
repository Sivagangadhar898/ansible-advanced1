#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0feb1eadee760c918
DOMAIN_NAME=joiningindevops.online
#here, mysql or mongodb instance_type should be t3.medium, for others it is t2.micro

    for i in $@
do

    if [[ $i == "mongodb" || $i == "mysql" ]]
then
    INSTANCE_TYPE="t3.medium"
else    
    INSTANCE_TYPE="t2.micro"
fi

    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"
    aws route53 change-resource-record-sets --hosted-zone-id Z05518102WFCFT3ITDVAC --change-batch '
    {
        "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                                 }}]
                        }
                        '
done