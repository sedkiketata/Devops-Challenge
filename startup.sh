#!/bin/bash

###
### Greeting
###
printf "Hi Fashion Cloud \nThis is a simple demonstration for the devops challenge \nBy SEDKI KETATA \n"

echo "*********************************"
echo "***  Please choose an option  ***"
echo "*********************************"


###
### Creation of a select Menu
### 
PS3="Please choose an option >> "
options=("Build the solution" "Test the solution" "Access to the Load Balancer" "Access to the Web Server 1" "Access to the Web Server 2" "Remove the solution" "Exit")
select opt in "${options[@]}";
do 
  	case $opt in 

		### 1 Option - Creating a nodejs webserver image (Docker) and build the infrastructure using Docker Swarm
		"Build the solution") 
		   docker build -t awesome:0.1 .
		   docker swarm init 
		   docker stack deploy --compose-file=docker-compose.yml prod
		   echo "\n"
		   ;;
		### End -- 1 Option

		### 2 Option - This will test that the LB works and redirect the requests to the two web servers each try
		"Test the solution")
		   var_ip=$(hostname -I | awk '{print $1}')
		   for i in `seq 1 10`;
		   do 
		   	curl http://$var_ip
			printf "\n"
           	   done
	           docker service ls 
		   printf "\n"
		   ;;
		### End -- 2 Option 

		### 3 Option - Give you the access to the LB directly using ssh
		"Access to the Load Balancer")
		   container_name=$(docker container ls | grep prod_proxy | awk '{print $15}')
	           docker container exec -it $container_name /bin/sh
		   ;;
		### End -- 3 Option

		### 4 Option - Give you the access directly to the web server number 1 
		"Access to the Web Server 1")
		   web1_name=$(docker container ls | grep prod_awesome.1. | awk '{print $12}')
		   docker container exec -it $web1_name /bin/bash
		   ;;
		### End -- 4 Option

		### 5 Option - Give you the access directly to the web server number 2
		"Access to the Web Server 2")
		   web2_name=$(docker container ls | grep prod_awesome.2. | awk '{print $12}')                    
		   docker container exec -it $web2_name /bin/bash
		   ;;
		### End -- 5 Option

		### 6 Option - Remove the entire solution that has been did in the first option
		"Remove the solution")
		   docker stack rm prod 
		   docker swarm leave --force 
		   docker image rm awesome:0.1
		   ;;
		### End -- 6 Option
		

		### 7 Option - You will quit the menu
		"Exit")
		   break
		   ;;
		### End -- 7 Option

		### Other Option
		*) echo "Invalid option Please retry " ;;
		### End -- Other Option
	esac
	REPLY=""
done

###
### End -- Creation of the select Menu
###
