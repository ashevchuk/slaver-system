cd /home/developer/local/sbin
./nginx -s stop
killall nginx
ps aux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill -9
