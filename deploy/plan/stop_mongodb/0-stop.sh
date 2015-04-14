cd /home/developer/devel/perl/Slaver/etc/single/init.d
./mongodb.stop
ps aux | grep mongod | grep -v grep | awk '{print $2}' | xargs kill -9
