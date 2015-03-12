#!/bin/bash

SERVICE_ROOT="/home/developer/devel/perl/Slaver/"

#SERVICE_INCLUDES+=" -I lib/WebAPI"

#SERVICE_MODULES+=" -MWebAPIConfig"

SERVICE_WORKERS="8"
SERVICE_ARGS="-d -e"

SERVICE_INTERPRETER="perl"
SERVICE_IMAGE="script/slaver_fastcgi.pl"

SERVICE_SOCKET_FILE="/home/developer/devel/perl/Slaver/var/run/slaver.sock"

SERVICE_PID_FILE="/home/developer/devel/perl/Slaver/var/run/slaver.pid"
SERVICE_PID=$(<$SERVICE_PID_FILE)
echo pid $SERVICE_PID

ORPHANED_PIDS=`ps ax -opid,ppid,args | awk '{if (($3 == "perl-fcgi") && ($2 == 1)) printf("%s ", $1);}'`

start() {
    echo Starting $SERVICE_IMAGE

    cd $SERVICE_ROOT
    $SERVICE_INTERPRETER $SERVICE_MODULES $SERVICE_INCLUDES $SERVICE_IMAGE -n $SERVICE_WORKERS -l $SERVICE_SOCKET_FILE -p $SERVICE_PID_FILE $SERVICE_ARGS
}

stop() {
    echo Killing $SERVICE_IMAGE

    kill -TERM $SERVICE_PID > /dev/null 2>&1

    sleep 1

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
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  *)
    echo "usage: $0 {start|stop|restart}"
esac
exit 0
