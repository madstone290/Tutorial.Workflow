#!/bin/bash

PUBLISH_DIR=/home/ubuntu/workflow/api/publish
BLUE_DEPLOY_DIR=/home/ubuntu/workflow/api/blue
GREEN_DEPLOY_DIR=/home/ubuntu/workflow/api/green

BLUE_CONF=/etc/nginx/sites-available/workflow-api-blue.conf
GREEN_CONF=/etc/nginx/sites-available/workflow-api-green.conf
UPSTREAM_CONF=/etc/nginx/sites-enabled/workflow-api-upstream.conf

BLUE_BASE_URL=localhost:33100
GREEN_BASE_URL=localhost:34100
BLUE_COLOR_URL=http://$BLUE_BASE_URL/UpstreamColor
GREEN_COLOR_URL=http://$GREEN_BASE_URL/UpstreamColor

BLUE_SERVICE=workflow-api-blue.service
GREEN_SERVICE=workflow-api-green.service



BLUE_COLOR=blue
GREEN_COLOR=green

TRUE=true
FALSE=false

getCurrentColor(){
	echo >&2 ">> curl -s $BLUE_COLOR_URL"
	blue_url_response="$(curl -s $BLUE_COLOR_URL)"
	echo >&2 ">> response: $blue_url_response"

	if [[ $blue_url_response == $BLUE_COLOR ]]
	then
		echo $BLUE_COLOR
		return
	fi

	echo >&2 ">> curl -s $GREEN_COLOR_URL"
	green_url_response="$(curl -s $GREEN_COLOR_URL)"
	echo >&2 ">> response: $green_url_response"

	if [[ $green_url_response == $GREEN_COLOR ]]
	then
		echo $GREEN_COLOR			
		return
	fi
}

getDeployColor(){
	current_color=$1
	echo >&2 ">> \$1 of getDisplayColor is $current_color"
	if [[ $current_color == $BLUE_COLOR ]]
	then
		echo $GREEN_COLOR
	else
		echo $BLUE_COLOR
	fi
}

deployBlueOrGreen(){
	deploy_dir=$1
	service=$2
	echo >&2 ">> \$1 of deployBlueOrGreen is $deploy_dir"
	echo >&2 ">> \$2 of deployBlueOrGreen is $service"

	# remove old files
	if [[ "$(ls -A $deploy_dir)" ]]
	then 
		rm $deploy_dir/*
	fi
	
	mv $PUBLISH_DIR/* $deploy_dir
	sudo systemctl start $service
}

deployBlue(){
	echo >&2 ">> deploy blue"
	deployBlueOrGreen $BLUE_DEPLOY_DIR $BLUE_SERVICE
}

deployGreen(){
	echo >&2 ">> deploy green"
	deployBlueOrGreen $GREEN_DEPLOY_DIR $GREEN_SERVICE
}

deploy(){
	if ! [[ "$(ls -A $PUBLISH_DIR)" ]]
	then 
		echo >&2 ">> Publish directory is empty"
		echo $FALSE
	fi

	if [[ $DEPLOY_COLOR == $BLUE_COLOR ]]
	then
		deployBlue	
	elif [[ $DEPLOY_COLOR == $GREEN_COLOR ]]
	then
		deployGreen
	else
		deployBlue
	fi
	echo $TRUE
}

healthCheck(){	
	if [[ $DEPLOY_COLOR == $BLUE_COLOR ]]
	then
		health_check_url=$BLUE_COLOR_URL
	else
		health_check_url=$GREEN_COLOR_URL
	fi
	
	for retry_count in {1..3}
	do
		
		echo >&2 ">> curl -s $health_check_url"
		response="$(curl -s $health_check_url)"
		echo >&2 ">> response: $response"
		if [[ $response == $GREEN_COLOR || $response == $BLUE_COLOR ]]
		then
			echo $TRUE
			return
		else
			echo >&2 ">> $retry_count of 3 fail"
		fi

		if [[ $retry_count -eq 3 ]]
		then
			echo $FALSE
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
	if [[ $DEPLOY_COLOR == $BLUE_COLOR ]]
	then
		switchToBlue
	elif [[ $DEPLOY_COLOR == $GREEN_COLOR ]]
	then
		switchToGreen
	else
		switchToBlue
	fi
}

deleteIdle(){
	if [[ $DEPLOY_COLOR ==  $BLUE_COLOR ]]
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

CURRENT_COLOR="$(getCurrentColor)"
echo >&2 "> Current color is $CURRENT_COLOR"

DEPLOY_COLOR="$(getDeployColor $CURRENT_COLOR)"
echo >&2 "> Deploy color is $DEPLOY_COLOR"

DEPLOY_RESULT="$(deploy)"
if [[ $DEPLOY_RESULT != $TRUE ]]
then
	echo >&2 "> Deployment is unsucessful"
	echo >&2 "> Exit with -1"
	exit -1
fi

HEALTH_CHECK_DELAY=7
echo >&2 "> Health check starts in $HEALTH_CHECK_DELAY"
delay $HEALTH_CHECK_DELAY

echo >&2 "> Start health check"
HEALTH_CHECK_RESULT=$(healthCheck)
if [[ $HEALTH_CHECK_RESULT != $TRUE ]]
then
	echo >&2 "> Deployed service is unhealthy"
	if [[ $DEPLOY_COLOR == $BLUE_COLOR ]]
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

