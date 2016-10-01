#!/bin/bash

aws ec2 run-instances --image-id ami-06b94666 --count 3 --key-name week3 --security-group-ids sg-a0df10d9 --instance-type t2.micro --user-data file://installapp.sh --placement AvailabilityZone=us-west-2a

aws elb create-load-balancer --load-balancer-name pmarcian-lb --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones us-west-2a

sleep 30

instanceNameArray=`aws ec2 describe-instances --filters Name=instance-state-name,Values=running --output text | cut -f8 | grep -E 'i-'`

aws elb register-instances-with-load-balancer --load-balancer-name pmarcian-lb --instances $instanceNameArray

aws autoscaling create-launch-configuration --launch-configuration-name week4lc --image-id ami-06b94666 --key-name week3 --instance-type t2.micro --user-data file://installapp.sh

aws autoscaling create-auto-scaling-group --auto-scaling-group-name week4asg --launch-configuration week4lc --availability-zone us-west-2a --load-balancer-name pmarcian-lb --max-size 5 --min-size 1 --desired-capacity 3

exit 0
