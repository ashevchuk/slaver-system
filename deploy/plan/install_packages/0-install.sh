#apt-get -y install libevent-dev
#apt-get install -y -q liblcms2-dev
#apt-get install -y -q liblcms2-2
#cd /home/developer/devel/perl/Slaver/var/tmp/upload_store
#./mkdir
#cd /home/developer/devel/perl/Slaver/var/tmp/upload_state
#./mkdir
#usermod -a -G fuse developer
cp /usr/home/developer/devel/perl/Slaver/etc/freebsd/newsyslog.conf.d/* /etc/newsyslog.conf.d/
echo 'newsyslog_enable="YES"' >> /etc/rc.conf
/etc/rc.d/newsyslog restart
