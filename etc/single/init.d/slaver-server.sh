#!/bin/bash

SERVICE_ROOT="/home/developer/devel/perl/Slaver/"

SERVICE_WORKERS="8"
SERVICE_ARGS="-d -e"

SERVICE_INTERPRETER="perl"
SERVICE_IMAGE="script/slaver_fastcgi.pl"

SERVICE_APPLICATION="Slaver"
SERVICE_APPLICATION_CMD="perl-fcgi-pm [$SERVICE_APPLICATION]"
SERVICE_APPLICATION_CMD_PID=$(ps ax -opid,ppid,args | awk '{if ($3" "$4 == "perl-fcgi-pm [Slaver]") print($1);}')

SERVICE_PID_FILE="${SERVICE_ROOT}var/run/slaver.pid"
SERVICE_SOCKET_FILE="${SERVICE_ROOT}var/run/slaver.sock"

#SERVICE_INCLUDES+=" -I lib/WebAPI"
#SERVICE_MODULES+=" -MWebAPIConfig"

ORPHANED_PIDS=$(ps ax -opid,ppid,args | awk '{if (($3 == "perl-fcgi") && ($2 == 1)) printf("%s ", $1);}')

if [ ! -f $SERVICE_PID_FILE ];
then
    echo -n "0" > $SERVICE_PID_FILE
fi

SERVICE_PID=$(<$SERVICE_PID_FILE)

if [ "$SERVICE_PID" != "0" ];
then
    echo Service pid $SERVICE_PID
fi

if [ "$SERVICE_APPLICATION_CMD_PID" != "" ];
then
    if [ "$SERVICE_APPLICATION_CMD_PID" != "$SERVICE_PID" ];
    then
	echo Service process $SERVICE_APPLICATION_CMD_PID exists, but not in the pid file
	SERVICE_PID=$SERVICE_APPLICATION_CMD_PID
    fi
fi

status() {
    echo Checking status $SERVICE_IMAGE

    if [ "$SERVICE_PID" != "0" ];
    then
	echo Service is running
	exit 0
    else
	echo Service is stopped
	exit 1
    fi
}

start() {
    echo Starting $SERVICE_IMAGE

    cd $SERVICE_ROOT
    $SERVICE_INTERPRETER $SERVICE_MODULES $SERVICE_INCLUDES $SERVICE_IMAGE -n $SERVICE_WORKERS -l $SERVICE_SOCKET_FILE -p $SERVICE_PID_FILE $SERVICE_ARGS
}

stop() {
    echo Killing $SERVICE_IMAGE

    if [ "$SERVICE_PID" == "0" ];
    then
	 echo "Service is already stoped"
    else
	kill -TERM $SERVICE_PID > /dev/null 2>&1
	sleep 1
    fi

    for ORPHANED_PID in $ORPHANED_PIDS; do
	echo Killing orphaned process: $ORPHANED_PID
	kill -KILL $ORPHANED_PID > /dev/null 2>&1
    done
}

case "$1" in
  start)
    stop
    sleep 1
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  *)
    echo "usage: $0 {start|stop|restart}"
esac

exit 0
