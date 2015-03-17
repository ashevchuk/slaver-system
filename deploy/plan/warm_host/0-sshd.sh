cd /etc/ssh
sed -i 's/Port 22$/Port 220/' ./sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' ./sshd_config
