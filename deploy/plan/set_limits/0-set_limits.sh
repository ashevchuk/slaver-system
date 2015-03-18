#ulimit -n64000 -u64000
#echo "*                soft    nofile          64000" >> /etc/security/limits.conf
#echo "*                hard    nofile          64000" >> /etc/security/limits.conf
#echo "*                soft    nproc           64000" >> /etc/security/limits.conf
#echo "*                hard    nproc           64000" >> /etc/security/limits.conf
echo 600> /sys/block/sda/device/timeout
echo 600> /sys/block/sr0/device/timeout
echo noop> /sys/block/sda/queue/scheduler
echo noop> /sys/block/sr0/queue/scheduler
echo never> /sys/kernel/mm/transparent_hugepage/defrag
echo 3> /proc/sys/vm/drop_caches
mount -oremount,noatime /
