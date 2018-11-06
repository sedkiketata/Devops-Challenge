#!/bin/bash

##
## This script will build the solution on Azure
##

# Default variables
my_ip="0.0.0.0" # w.x.y.z/n format
mask="0"
group_name="swarm"
t=10
leaders=1
workers=2

# Microsoft AZURE Variables
id=""
location="West Europe"

source ./box.sh

box "Creating A Docker Machine to Manage Azure Hosts"
docker-machine create \
      --driver azure \
      --azure-location $location \
      --azure-subscription-id $id \
      leader1

ip=$(docker-machine ssh leader1 ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
for node in $(seq 1 $workers);
do
   box "Node worker $node" "light-purple" "red"
   docker-machine create \
      --driver azure \
      --azure-location $location \
      --azure-subscription-id $id \
      worker$node 
done

eval "$(docker-machine env leader1)"

docker swarm init --listen-addr $ip --advertise-addr $ip
workertok=$(docker swarm join-token -q worker)
for node in $(seq 1 $workers);
do
   eval "$(docker-machine env worker$node)"
   docker swarm join --token $workertok $ip:2377
done

eval $(docker-machine env leader1)
## box "Overlay Network creation" "light_purple" "blue"
docker network create -d overlay swarmnet
## box "Starting WebStack services" "light_green" "green"
docker service create --name web1 --network swarmnet --publish 8080:8080 awesome:0.1
docker service create --name web2 --network swarmnet --publish 8080:8080 awesome:0.1
docker service create --name lb   --network swarmnet --publish 80:80 dockercloud/haproxy
sleep $t

# Azure firewall rules
azure config mode arm
for node in $(seq 1 $leaders);
do
   azure network nsg show docker-machine leader$node-firewall
   azure network nsg rule create docker-machine leader$node-firewall http --priority $priority --protocol tcp --destination-port-range 80 --source-address-prefix $my_ip
   azure network nsg rule create docker-machine leader$node-firewall http --priority $priority --protocol tcp --destination-port-range 8080 --source-address-prefix $my_ip
   priority=$(expr $priority + 1)
done
for node in $(seq 1 $workers);
do
   azure network nsg show docker-machine worker$node-firewall
   azure network nsg rule create docker-machine worker$node-firewall http --priority $priority --protocol tcp --destination-port-range 80 --source-address-prefix $my_ip
   priority=$(expr $priority + 1)
done

docker run -it -d -p 5000:5000 -e HOST=$(docker-machine ip leader1) -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer
# box "Open web browser to visualize cluster" "light_purple" "green"
# open http://$(docker-machine ip leader1):5000

# box "To scale type:eval \$(docker-machine env leader1) && docker service scale web=10" "red" "red"
# box "To remove swarm cluster and cleanup: ./remove.sh" "red" "red"
