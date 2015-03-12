#!/bin/bash

#HOME=/home/developer

IMAGE_MAGICK=$(wget http://www.imagemagick.org/script/download.php -O - | grep "The latest release of ImageMagick is version" | perl -pe 's/^.*?\sversion\s(.*?)\.\<.*?$/$1/sg')

PERL=$(perlbrew info | grep "Name" | perl -pe 's/^.*?\s*perl\-//')

CPU_CORES_NUM=$(nproc)

BUILD_DIR=/tmp/im_build_$IMAGE_MAGICK

echo "ImageMagick last version: $IMAGE_MAGICK"
echo "used perl: $PERL"
echo "home: $HOME"
echo "cpu cores: $CPU_CORES_NUM"

rm -rf $BUILD_DIR

mkdir $BUILD_DIR

cd $BUILD_DIR

wget http://www.imagemagick.org/download/ImageMagick-$IMAGE_MAGICK.tar.gz
tar -zxvf ImageMagick-$IMAGE_MAGICK.tar.gz

cd ImageMagick-$IMAGE_MAGICK

LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/x86_64-linux-thread-multi-ld/CORE"
MAGICK_LDFLAGS="-fPIC -L/usr/local/lib -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/x86_64-linux-thread-multi-ld/CORE -lfreetype"
CFLAGS="-fPIC"
./configure CFLAGS="-fPIC" \
    MAGICK_LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/x86_64-linux-thread-multi-ld/CORE" \
    LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/x86_64-linux-thread-multi-ld/CORE" \
    --prefix $HOME/local \
    --with-perl=$HOME/perl5/perlbrew/perls/perl-$PERL/bin/perl \
    --enable-shared \
    --without-gcc-arch

make -j$CPU_CORES_NUM

make install

rm -rf $BUILD_DIR

export LD_LIBRARY_PATH=$HOME/local/lib
