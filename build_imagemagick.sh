#!/bin/bash

#HOME=/home/developer

IMAGE_MAGICK=$(wget http://www.imagemagick.org/script/download.php -O - | grep "The latest release of ImageMagick is version" | perl -pe 's/^.*?\sversion\s(.*?)\.\<.*?$/$1/sg')

#IMAGE_MAGICK="6.9.0-10"

PERL=$(perlbrew info | grep "Name" | perl -pe 's/^.*?\s*perl\-//')

CPU_CORES_NUM=$(sysctl -a | egrep -i 'hw.ncpu' | awk '{print $2}')

BUILD_DIR=/tmp/im_build_$IMAGE_MAGICK

echo "ImageMagick last version: $IMAGE_MAGICK"
echo "used perl: $PERL"
echo "home: $HOME"
echo "cpu cores: $CPU_CORES_NUM"

rm -rf $BUILD_DIR

mkdir $BUILD_DIR

cd $BUILD_DIR

wget http://www.imagemagick.org/download/releases/ImageMagick-$IMAGE_MAGICK.tar.gz
tar -zxvf ImageMagick-$IMAGE_MAGICK.tar.gz

export LD_LIBRARY_PATH=$HOME/local/lib

cd ImageMagick-$IMAGE_MAGICK

gmake clean

LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib"
MAGICK_LDFLAGS="-fPIC -L/usr/local/lib -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -lfreetype"
CFLAGS="-fPIC"
./configure CFLAGS="-fPIC" \
    MAGICK_LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib" \
    LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib" \
    --prefix $HOME/local \
    --enable-shared \
    --enable-portable-binary \
    --without-gcc-arch \
    --with-perl=$HOME/perl5/perlbrew/perls/perl-$PERL/bin/perl

gmake

gmake install

rm -rf $BUILD_DIR

export LD_LIBRARY_PATH=$HOME/local/lib
