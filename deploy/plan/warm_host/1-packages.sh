sed -i 's/deb http:\/\/non-us.debian.org\/debian-non-US stable\/non-US main contrib non-free//' /etc/apt/sources.list
apt-get update --force-yes -y
apt-get upgrade --force-yes -y
apt-get install --force-yes -y git mercurial gcc libpcre++-dev libssl-dev make cmake automake autoconf clang g++ libpng++-dev libjpeg-dev libdb++-dev libdb-dev libxml2-dev zlibc expat libexpat-dev libgmp-dev ntp tmux mc ghostscript djvulibre-bin libdjvulibre-dev liblcms liblcms-dev liblcms1-dev liblcms2-dev libfreetype6-dev libxft-dev libxft2-dev libxft2 sshfs vpx-tools chm2pdf libevent-dev
