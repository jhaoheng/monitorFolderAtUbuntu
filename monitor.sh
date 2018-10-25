#!/bin/bash

# check MONITOR_FOLDER exist
if [ -z $MONITOR_FOLDER ]; then
    MONITOR_FOLDER="/tmp"
fi
if [ -e $MONITOR_FOLDER ]; then
	mkdir -p $MONITOR_FOLDER
fi

# Execute, when 'MONITOR_FOLDER' [create | delete] any file
actionJob(){
	if [ -e $(pwd)/log ]; then
		touch $(pwd)/log
	fi
	echo "$(date +"%F %T") $1 $2 $3" >> $(pwd)/log # use logrotate to backlog & rotate
}

# Stop Monitor
stop(){
    pid=$(ps aux | grep inotifywait | grep -v grep | awk '{print $2}')
	if [ $pid ]; then
		printf "\n== disable ==\n"
		ps aux | grep inotifywait
		kill -9 $pid
		wait $pid 2>/dev/null
		echo ""
	else
		state
	fi
}

# Start Monitor
start(){
	pid=$(ps aux | grep inotifywait | grep -v grep | awk '{print $2}')

	if [ $pid ]; then
		state
	else
		printf "\n== enable ==\n"
		echo "Monitor : "$MONITOR_FOLDER

		inotifywait -m -q -e create -e delete --format '%e %w%f' $MONITOR_FOLDER | while read evt dir file
		do
			actionJob $evt $dir $file
		done | &>/dev/null &

		echo "pid is "$(ps aux | grep inotifywait | grep -v grep | awk '{print $2}')
		echo ""
	fi
}

# Check Monitor state
state(){
	pid=$(ps aux | grep inotifywait | grep -v grep | awk '{print $2}')
	if [ -z $pid ]; then
		echo "Monitor Not Work"	
	else
		echo "Monitor Work ON"
		echo "pid is : "$pid 
	fi
}

if [ "$1" = "start" ]
then
    start
elif [ "$1" = "stop" ]
then
    stop
elif [ "$1" = "state" ]
then
	state
else
    printf "\n== Monitor [CREATE | DELETE] at [$MONITOR_FOLDER] ==\n\n"
    echo "use [cmd]"
    echo "  start : Run "
    echo "  stop : "
	echo "  state : "
	echo ""
fi