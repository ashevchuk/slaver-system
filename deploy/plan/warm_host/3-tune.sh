echo 600> /sys/block/sda/device/timeout
echo 600> /sys/block/sr0/device/timeout
echo noop> /sys/block/sda/queue/scheduler
echo noop> /sys/block/sr0/queue/scheduler
echo never> /sys/kernel/mm/transparent_hugepage/defrag
echo 'echo 600> /sys/block/sda/device/timeout' >> /etc/rc.local
echo 'echo 600> /sys/block/sr0/device/timeout' >> /etc/rc.local
echo 'echo never> /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.loca
echo 'echo noop> /sys/block/sda/queue/scheduler' >> /etc/rc.loca
echo 'echo noop> /sys/block/sr0/queue/scheduler' >> /etc/rc.loca
echo 'net.ipv4.conf.all.accept_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.eth0.accept_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_redirects = 0' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 996777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 996777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 4194304' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 786432 1048576 996777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 87380 4194304' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_orphans = 2255360' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 10000' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 10' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_intvl = 15' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 2048' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_synack_retries = 1' >> /etc/sysctl.conf
echo 'kernel.msgmnb = 65536' >> /etc/sysctl.conf
echo 'kernel.msgmax = 65536' >> /etc/sysctl.conf
echo 'kernel.shmmax = 494967295' >> /etc/sysctl.conf
echo 'kernel.shmall = 268435456' >> /etc/sysctl.conf
echo 'net.core.somaxconn = 16096' >> /etc/sysctl.conf
