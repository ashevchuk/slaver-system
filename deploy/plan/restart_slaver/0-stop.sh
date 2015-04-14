cd /home/developer/devel/perl/Slaver/etc/single/init.d
./slaver stop
#cd /home/developer/devel/perl/Slaver/script/styx
#./host_stats.pl stop
cd /home/developer/devel/perl/Slaver/script/misc/service/image/convert
./converter.pl stop
kill -9 $(ps aux | grep convert | grep -v grep | awk '{print $2}')
#kill -9 $(ps aux | grep host_stats | grep -v grep | awk '{print $2}')
#/home/developer/bin/mongo queue --eval "db.dropDatabase()"
#rm -f /tmp/cpustats.yml
