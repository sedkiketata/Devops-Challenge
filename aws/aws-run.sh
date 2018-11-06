#!/bin/bash

##
## Script for creating the solution under AWS
##

t=10 
leaders=1 
workers=2 
my_ip="0.0.0.0" # w.x.y.z/n format 
mask="0" 
group_name="swarm"

export AWS_ACCESS_KEY_ID="" 
export AWS_SECRET_ACCESS_KEY="" 
export AWS_DEFAULT_REGION="eu-west-3" 
export region="eu-west-3"

##
## Setting a new security group
##

aws ec2 create-security-group --group-name ${group_name} --description "A Security Group for Docker Networking" > /dev/null 2>&1
# Permit SSH, required for Docker Machine 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 22    --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 2376  --cidr ${my_ip}/${mask} 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 2377  --cidr ${my_ip}/${mask} 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 7946  --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol udp --port 7946  --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol udp --port 4789  --cidr 0.0.0.0/0

# Permit Web - LB Services
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 8080  --cidr ${my_ip}/${mask}
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 80    --cidr ${my_ip}/${mask}
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 5000  --cidr ${my_ip}/${mask}

docker-machine create \
    	--driver amazonec2 \
    	--amazonec2-region ${region} \
    	--amazonec2-security-group ${group_name} \
    	leader1

	
wait
ip=$(docker-machine ssh leader1 ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)

for node in $(seq 1 $workers); do    
	docker-machine create \
	    	--driver amazonec2 \
	    	--amazonec2-region ${region} \
	    	--amazonec2-security-group ${group_name} \
	    	worker$n
done
wait

eval "$(docker-machine env leader1)"
docker swarm init --listen-addr $ip --advertise-addr $ip
workertok=$(docker swarm join-token -q worker)
for node in $(seq 1 $workers);
do
	eval "$(docker-machine env worker$node)"
	docker swarm join --token $workertok $ip:2377
done
eval $(docker-machine env leader1)
docker network create -d overlay swarmnet

docker stack deploy --compose-file docker-stack.yml prod
