#!/bin/bash
# now with positional parameters
# AMI ID      , key-name, security-group, launch-configuration, count
# ami-06b94666, week3   , sg-a0df10d9   , week4lc             , #
# $1          , $2      , $3            , $4                  , $5
# Peter Marciano II
# Week 4 Assignment

if [ $# -eq 5 ]; then

  aws ec2 run-instances --image-id $1 --count $5 --key-name $2 --security-group-ids $3 --instance-type t2.micro --user-data file://installapp.sh --placement AvailabilityZone=us-west-2a

  aws elb create-load-balancer --load-balancer-name pmarcian-lb --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones us-west-2a

  sleep 30

  instanceNameArray=`aws ec2 describe-instances --filters Name=instance-state-name,Values=running --output text | cut -f8 | grep -E 'i-'`

  aws elb register-instances-with-load-balancer --load-balancer-name pmarcian-lb --instances $instanceNameArray

  aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --instance-type t2.micro --user-data file://installapp.sh

  aws autoscaling create-auto-scaling-group --auto-scaling-group-name week4asg --launch-configuration $4 --availability-zone us-west-2a --load-balancer-name pmarcian-lb --max-size 5 --min-size 1 --desired-capacity 3
else
  echo "You need 5 positional parameters!"
  echo "ami id, key-name, security-group, launch-config, count"
  exit 1
fi

exit 0
