#!/bin/bash

#grab associated instance ids
instanceNameArray=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name week4asg | cut -f4 | grep -E 'i-'`

#aws autoscaling detach load-balancers from autoscaling group
aws autoscaling detach-load-balancers --load-balancer-names pmarcian-lb --auto-scaling-group-name week4asg

#aws autoscaling delete autoscaling configuration
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name week4asg --force-delete

#wait for instances to terminate
aws ec2 wait instance-terminated --instance-ids $instanceNameArray


#aws autoscaling delete-launch configuration
aws autoscaling delete-launch-configuration --launch-configuration-name week4lc

#aws elb de register instances from load-balancer
aws elb deregister-instances-from-load-balancer --load-balancer-name pmarcian-lb --instances $instanceNameArray

#aws elb delete listeners
aws elb delete-load-balancer-listeners --load-balancer-name pmarcian-lb --load-balancer-ports 80

#aws elb delete load-balancers
aws elb delete-load-balancer --load-balancer-name pmarcian-lb

#aws ec2 terminate-instances
#aws ec2 terminate-instances --instance-ids $instanceNameArray

exit 0
