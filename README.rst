Slaver
============

Distributed Smart System. Version 0.01093.

**MongoDB** configuration script
============

sh.addShard( "nodeX.enslaver.net:27018" )

use content
db.content.ensureIndex( { "$**": "text" }, { name: "All_FT_Idx" } )

use admin

sh.enableSharding("auth")
sh.enableSharding("thumbnails")
sh.enableSharding("avatars")
sh.enableSharding("data")
sh.enableSharding("blackboard")
sh.enableSharding("queue")
sh.enableSharding("log")
sh.enableSharding("content")

db.slaver.ensureIndex( { "maxlife": 1 }, { expireAfterSeconds: 1440 } )

sh.shardCollection( "auth.sessions", { _id : 1 } )
sh.shardCollection( "auth.users", { username : "hashed" } )
sh.shardCollection( "data.fs.chunks" , { files_id : 1 , n : 1 } )
sh.shardCollection( "data.fs.files", { _id : 1 } )
#sh.shardCollection( "blackboard.host.sys.stats", { host : "hashed" } )
#sh.shardCollection( "queue.service.image.convert", { host : "hashed" } )
sh.shardCollection( "log.slaver", { host : "hashed" } )
sh.shardCollection( "content.content", { _id : 1 } )
sh.shardCollection( "content.menu", { role : "hashed" } )

use content
db.menu.ensureIndex( { role : "hashed" } )
db.votes.ensureIndex( { "issue": 1 }, { expireAfterSeconds: 1440 } )

use queue
db['service.image.convert'].ensureIndex({ host : "hashed" })

use blackboard
db['blackboard.host.sys.stats'].ensureIndex( { _id : 1 , host : "hashed" } )

use auth
db.users.ensureIndex( { _id : 1 , username : "hashed" } )

db.sessions.ensureIndex( { "issue": 1 }, { expireAfterSeconds: 43200 } )

db.runCommand( { collMod: "sessions", index: { keyPattern: { issue: 1 }, expireAfterSeconds: 43200 } } )

use data/thumbnails/avatars
db.fs.chunks.ensureIndex( { files_id : 1 , n : 1 } )
db.runCommand( { shardCollection : "data.fs.chunks" , key : { files_id : 1 , n : 1 } } )

db.fs.files.ensureIndex( { _id : 1 } )
db.runCommand( { shardCollection : "data.fs.files" , key : { _id : 1 } } )

use data
db.fs.files.ensureIndex( { host : "hashed" } )

use log
db.slaver.ensureIndex( { host : "hashed" } )

db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000000"), "owner" : "main", "sub_id" : "", "caption" : "Home", "description" : "Home Page", "alias" : "home", "role" : "category", "icon" : "fa fa-home", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000001"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000000", "caption" : "About", "description" : "About Page", "alias" : "about", "role" : "category", "icon" : "fa fa-group", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000002"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000000", "caption" : "Contacts", "description" : "Contacts Page", "alias" : "contacts", "role" : "category", "icon" : "fa fa-envelope", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000003"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000000", "caption" : "Users", "description" : "Users Page", "alias" : "users", "role" : "category", "icon" : "fa fa-user", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000004"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000000", "caption" : "Labs", "description" : "Labs Page", "alias" : "labs", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000005"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000004", "caption" : "Labs 0", "description" : "Labs0 Page", "alias" : "labs-0", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000006"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000004", "caption" : "Labs 1", "description" : "Labs1 Page", "alias" : "labs-1", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000007"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000004", "caption" : "Labs 2", "description" : "Labs2 Page", "alias" : "labs-2", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000008"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000007", "caption" : "Labs 2 0", "description" : "Labs20 Page", "alias" : "labs-2-0", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f000009"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000000", "caption" : "Tech Labs", "description" : "Tech Labs Page", "alias" : "tech-labs", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f00000a"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000009", "caption" : "Tech Labs 0", "description" : "Tech Labs0 Page", "alias" : "tech-labs-0", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f00000b"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000009", "caption" : "Tech Labs 1", "description" : "Tech Labs1 Page", "alias" : "tech-labs-1", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f00000c"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f000009", "caption" : "Tech Labs 2", "description" : "Tech Labs2 Page", "alias" : "tech-labs-2", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })
db.menu.save({ "_id" : ObjectId("514c2e7c08e4a52d1f00000d"), "owner" : "main", "sub_id" : "514c2e7c08e4a52d1f00000c", "caption" : "Tech Labs 2 0", "description" : "Tech Labs20 Page", "alias" : "tech-labs-2-0", "role" : "category", "icon" : "fa fa-graduation-cap", "_class" : "Content::Menu" })

Smoke test
============

    $ ./script/slaver_test.pl

**Debian** requirements script
============

apt-get install git mercurial
apt-get install gcc libpcre++-dev libssl-dev
apt-get install make cmake automake autoconf
apt-get install clang g++
apt-get install libpng++-dev libjpeg-dev
apt-get install libdb++-dev libdb-dev
apt-get install libxml2-dev zlibc
apt-get install expat libexpat-dev
apt-get install libgmp-dev
apt-get install -y ntp
apt-get install -y tmux mc
apt-get install -y ghostscript
apt-get install -y djvulibre-bin
apt-get install -y libdjvulibre-dev
apt-get install -y liblcms
apt-get install -y liblcms-dev
apt-get install -y liblcms1-dev
apt-get install -y liblcms2-dev
apt-get install -y libfreetype6-dev
apt-get install -y libxft-dev
apt-get install -y libxft2-dev
apt-get install -y libxft2
apt-get install -y sshfs
apt-get install -y vpx-tools
apt-get install -y chm2pdf
apt-get install -y libevent-dev
apt-get install -y liblcms2-2
apt-get install -y liblcms2-dev

Install all
============

    $ git clone https://github.com/ashevchuk/slaver-system.git

    $ apt-get install -y git mercurial gcc libpcre++-dev libssl-dev make cmake automake autoconf clang g++ libpng++-dev libjpeg-dev libdb++-dev libdb-dev libxml2-dev zlibc expat libexpat-dev libgmp-dev ntp tmux mc ghostscript djvulibre-bin libdjvulibre-dev liblcms liblcms-dev liblcms1-dev liblcms2-dev libfreetype6-dev libxft-dev libxft2-dev libxft2 sshfs vpx-tools chm2pdf libevent-dev liblcms2-2 liblcms2-dev

    $ wget http://download.zeromq.org/zeromq-3.2.4.tar.gz
    $ ./configure --prefix=/home/developer/local

Configure Environment
============

    $ echo 'export LD_LIBRARY_PATH=$HOME/local/lib' >> ~/.bash_profile
    $ echo 'export ZMQ_HOME=$HOME/local' >> ~/.bash_profile

Add Multimedia sources
============

    $ wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2014.2_all.deb
    $ dpkg -i deb-multimedia-keyring_2014.2_all.deb

    $ echo 'deb http://www.deb-multimedia.org squeeze main' >> /etc/apt/sources.list
    $ echo 'deb http://www.deb-multimedia.org jessie main non-free' >> /etc/apt/sources.list

Setup **NTP**
============

    $ echo "logfile /var/log/xntpd" > /etc/ntp.conf
    $ echo "driftfile /var/lib/ntp/ntp.drift" >> /etc/ntp.conf
    $ echo "statsdir /var/log/ntpstats/" >> /etc/ntp.conf
    $ echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
    $ echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
    $ echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
    $ echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf
    $ echo "server 0.pool.ntp.org iburst" >> /etc/ntp.conf
    $ echo "server 1.pool.ntp.org iburst" >> /etc/ntp.conf
    $ echo "server 2.pool.ntp.org iburst" >> /etc/ntp.conf
    $ echo "server 3.pool.ntp.org iburst" >> /etc/ntp.conf

    $ dpkg-reconfigure tzdata
    $ dpkg-reconfigure ntp

Setup IO Timeouts
============

    $ echo 600> /sys/block/sda/device/timeout
    $ echo 600> /sys/block/sr0/device/timeout

    $ echo 'echo 600> /sys/block/sda/device/timeout' >> /etc/rc.local
    $ echo 'echo 600> /sys/block/sr0/device/timeout' >> /etc/rc.local

    $ echo 'echo noop> /sys/block/sda/queue/scheduler' >> /etc/rc.local
    $ echo 'echo noop> /sys/block/sr0/queue/scheduler' >> /etc/rc.local

    $ echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local

Setup Limits
============

    $ echo '*                soft    nofile          64000' >> /etc/security/limits.conf
    $ echo '*                hard    nofile          64000' >> /etc/security/limits.conf
    $ echo '*                soft    nproc           64000' >> /etc/security/limits.conf
    $ echo '*                hard    nproc           64000' >> /etc/security/limits.conf

Setup System Paramenters
============

    $ echo 'net.ipv4.conf.all.accept_redirects = 0' >> /etc/sysctl.conf
    $ echo 'net.ipv4.conf.eth0.accept_redirects = 0' >> /etc/sysctl.conf
    $ echo 'net.ipv4.conf.default.accept_redirects = 0' >> /etc/sysctl.conf
    $ echo 'net.core.rmem_max = 996777216' >> /etc/sysctl.conf
    $ echo 'net.core.wmem_max = 996777216' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_rmem = 4096 87380 4194304' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_mem = 786432 1048576 996777216' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_wmem = 4096 87380 4194304' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_max_orphans = 2255360' >> /etc/sysctl.conf
    $ echo 'net.core.netdev_max_backlog = 10000' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_fin_timeout = 10' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_keepalive_intvl = 15' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_max_syn_backlog = 2048' >> /etc/sysctl.conf
    $ echo 'net.ipv4.tcp_synack_retries = 1' >> /etc/sysctl.conf
    $ echo 'kernel.msgmnb = 65536' >> /etc/sysctl.conf
    $ echo 'kernel.msgmax = 65536' >> /etc/sysctl.conf
    $ echo 'kernel.shmmax = 494967295' >> /etc/sysctl.conf
    $ echo 'kernel.shmall = 268435456' >> /etc/sysctl.conf
    $ echo 'net.core.somaxconn = 16096' >> /etc/sysctl.conf
