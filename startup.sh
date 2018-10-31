printf "Hi Fashion Cloud \nThis is a simple demonstration for the devops challenge \nBy SEDKI KETATA \n"

echo "*********************************"
echo "***  Please choose an option  ***"
echo "*********************************"

PS3="Please choose an option >> "
options=("Build the solution" "Test the solution" "Access to the Load Balancer" "Access to the Web Server 1" "Access to the Web Server 2" "Exit")
select opt in "${options[@]}";
do 
  	case $opt in 
		"Build the solution") 
		   docker build -t awesome:0.1 .
		   docker swarm init 
		   docker stack deploy --compose-file=docker-compose.yml prod
		   echo "\n"
		   ;;
		"Test the solution")
		   var_ip=$(hostname -I | awk '{print $1}')
		   for i in `seq 1 10`;
		   do 
		   	curl http://$var_ip
			echo "\n"
           	   done
		   ;;
		"Access to the Load Balancer") echo "you choose 3"
		   ;;
		"Access to the Web Server 1") echo "you choose 4"
		   ;;
		"Access to the Web server 2") echo "you choose 5"
		   ;;
		"Exit") echo "you choose 6"
		     break
		   ;;
		*) echo "Invalid option Please retry " ;;
	esac
done
