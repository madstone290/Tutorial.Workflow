#!/bin/bash

API_PUBLISH=/home/ubuntu/workflow/publish
BLUE_API_DEPLOY=/home/ubuntu/workflow/blue/api
GREEN_API_DEPLOY=/home/ubuntu/workflow/green/api

BLUE_CONF=/etc/nginx/sites-available/workflow-blue.conf
GREEN_CONF=/etc/nginx/sites-available/workflow-green.conf
UPSTREAM_CONF=/etc/nginx/sites-enabled/workflow-upstream.conf

BLUE_WEB_URL=localhost:33000
BLUE_API_URL=localhost:33100
GREEN_WEB_URL=localhost:34000
GREEN_API_URL=localhost:34100

BLUE_SERVICE=workflow-blue.service
GREEN_SERVICE=workflow-green.service

UPSTREAM_COLOR_ROUTE=UpstreamColor

getCurrentColor(){
	blue_url=http://$BLUE_API_URL/$UPSTREAM_COLOR_ROUTE
	echo >&2 ">> curl -s $blue_url"
	blue_url_response="$(curl -s $blue_url)"
	echo >&2 ">> response: $blue_url_response"

	if [ "$blue_url_response" == "blue" ]
	then
		echo "blue"
		return
	fi

	green_url=http://$GREEN_API_URL/$UPSTREAM_COLOR_ROUTE
        echo >&2 ">> curl -s $green_url"
        green_url_response="$(curl -s $green_url)"
        echo >&2 ">> response: $green_url_response"

	if [ "$green_url_response" == "green" ]
	then
		echo "green"			
		return
	fi

	echo "null"
}

getDeployColor(){
	current_color=$1
	echo >&2 ">> \$1 of getDisplayColor is $current_color"
	if [ "$current_color" == "blue" ]
	then
		echo "green"
	else
		echo "blue"
	fi
}

deployBlueOrGreen(){
	deploy_dir=$1
	service=$2
	echo >&2 ">> \$1 of deployBlueOrGreen is $deploy_dir"
	echo >&2 ">> \$2 of deployBlueOrGreen is $service"

	# remove old files
	if [ "$(ls -A $deploy_dir)" ]
	then 
		rm $deploy_dir/*
	fi
	
	mv $API_PUBLISH/* $deploy_dir
	sudo systemctl start $service
}

deployBlue(){
	echo >&2 ">> deploy blue"
	deployBlueOrGreen $BLUE_API_DEPLOY $BLUE_SERVICE
}

deployGreen(){
	echo >&2 ">> deploy green"
	deployBlueOrGreen $GREEN_API_DEPLOY $GREEN_SERVICE
}

deploy(){
	if ! [ "$(ls -A $API_PUBLISH)" ]
	then 
		echo >&2 ">> Publish directory is empty"
		echo "false"
	fi

	if [ "$DEPLOY_COLOR" == "blue" ]
	then
		deployBlue	
	elif [ "$DEPLOY_COLOR" == "green" ]
	then
		deployGreen
	else
		deployBlue
	fi
	echo "true"
}

healthCheck(){	
	if [ "$DEPLOY_COLOR" == "blue" ]
	then
		health_check_url=http://$BLUE_API_URL/$UPSTREAM_COLOR_ROUTE
	else
		health_check_url=http://$GREEN_API_URL/$UPSTREAM_COLOR_ROUTE
	fi
	
	for retry_count in {1..3}
	do
		
		echo >&2 ">> curl -s $health_check_url"
		response="$(curl -s $health_check_url)"
		echo >&2 ">> response: $response"
		if [[ "$response" == "green" || "$response" == "blue" ]]
		then
			echo "true"
			return
		else
			echo >&2 ">> $retry_count of 3 fail"
		fi

		if [ $retry_count -eq 3 ]
		then
			echo "false"
			return
		fi

		sleep 3
	done
}

switchToBlue(){
	echo >&2 ">> Switch to blue"
	sudo ln -sf $BLUE_CONF $UPSTREAM_CONF
	sudo systemctl reload nginx
}

switchToGreen(){
	echo >&2 ">> Swith to green"
	sudo ln -sf $GREEN_CONF $UPSTREAM_CONF
	sudo systemctl reload nginx
}

switch(){
	if [ "$DEPLOY_COLOR" == "blue" ]
	then
		switchToBlue
	elif [ "$DEPLOY_COLOR" == "green" ]
	then
		switchToGreen
	else
		switchToBlue
	fi
}

deleteIdle(){
	if [ "$DEPLOY_COLOR" == "blue" ]
	then
		service=$GREEN_SERVICE
	else
		service=$BLUE_SERVICE	
	fi
	
	echo >&2 ">> Delete $service"
	sudo systemctl stop $service
}

delay(){
	delay_second=$1
	for (( second = $delay_second; second > 0; second--))
	do
		echo >&2 ">> $second seconds remain"
		sleep 1
	done
}

CURRENT_COLOR=$(getCurrentColor)
echo >&2 "> Current color is $CURRENT_COLOR"

DEPLOY_COLOR=$(getDeployColor $CURRENT_COLOR)
echo >&2 "> Deploy color is $DEPLOY_COLOR"

DEPLOY_RESULT=$(deploy)
if [ "$DEPLOY_RESULT" != "true" ]
then
	echo >&2 "> Deployment is unsucessful"
	echo >&2 "> Exit with -1"
	exit -1
fi

echo >&2 "> Deployment is sucessful"

HEALTH_CHECK_DELAY=7
echo >&2 "> Health check starts in $HEALTH_CHECK_DELAY"
delay $HEALTH_CHECK_DELAY

echo >&2 "> Start health check"
HEALTH_CHECK_RESULT=$(healthCheck)
if [ "$HEALTH_CHECK_RESULT" != "true" ]
then
	echo >&2 "> Deployed service is unhealthy"
	if [ "$DEPLOY_COLOR" == "blue" ]
	then
		service_to_stop=$BLUE_SERVICE
	else
		service_to_stop=$GREEN_SERVICE	
	fi

	echo >&2 "> Stop $service_to_stop"
	sudo systemctl stop $service_to_stop
	echo >&2 "> Exit with -1"
	exit -1
fi

echo >&2 "> Deployed service is healthy"

echo >&2 "> Switch service"
switch

DELETE_SERVICE_DELAY=3
echo >&2 "> Delete service in $DELETE_SERVICE_DELAY"
delay $DELETE_SERVICE_DELAY

echo >&2 "> Delete service"
deleteIdle

exit 0

