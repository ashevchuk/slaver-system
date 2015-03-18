echo "logfile /var/log/xntpd" > /etc/ntp.conf
echo "driftfile /var/lib/ntp/ntp.drift" >> /etc/ntp.conf
echo "statsdir /var/log/ntpstats/" >> /etc/ntp.conf
echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf
echo "server 0.pool.ntp.org iburst" >> /etc/ntp.conf
echo "server 1.pool.ntp.org iburst" >> /etc/ntp.conf
echo "server 2.pool.ntp.org iburst" >> /etc/ntp.conf
echo "server 3.pool.ntp.org iburst" >> /etc/ntp.conf
echo "Etc/UTC" > /etc/timezone
dpkg-reconfigure ntp
