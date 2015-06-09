#!/bin/bash

#HOME=/home/developer

IMAGE_MAGICK=$(wget http://www.imagemagick.org/script/download.php -O - | grep "The latest release of ImageMagick is version" | perl -pe 's/^.*?\sversion\s(.*?)\.\<.*?$/$1/sg')

#IMAGE_MAGICK="6.9.0-10"

PERL=$(perlbrew info | grep "Name" | perl -pe 's/^.*?\s*perl\-//')

CPU_CORES_NUM=$(sysctl -a | egrep -i 'hw.ncpu' | awk '{print $2}')

BUILD_DIR=/home/developer/tmp/im_build_$IMAGE_MAGICK
IM_ARCHIVE=$BUILD_DIR/ImageMagick-$IMAGE_MAGICK.tar.gz

echo "ImageMagick last version: $IMAGE_MAGICK"
echo "used perl: $PERL"
echo "home: $HOME"
echo "build dir: $BUILD_DIR"
echo "cpu cores: $CPU_CORES_NUM"

#rm -rf $BUILD_DIR

mkdir $BUILD_DIR

cd $BUILD_DIR

if [ ! -f $IM_ARCHIVE ]; then
    echo "File not found!"
    wget http://www.imagemagick.org/download/releases/ImageMagick-$IMAGE_MAGICK.tar.gz
fi

rm -rf $BUILD_DIR/ImageMagick-$IMAGE_MAGICK

tar -zxvf ImageMagick-$IMAGE_MAGICK.tar.gz

export LD_LIBRARY_PATH=$HOME/local/lib

cd ImageMagick-$IMAGE_MAGICK

gmake clean

LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib -L/home/developer/local/lib"
MAGICK_LDFLAGS="-fPIC -L/usr/local/lib -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -lfreetype -L/home/developer/local/lib"
CFLAGS="-fPIC"
./configure \
    CFLAGS="-fPIC -I/home/developer/local/include" \
    CPPFLAGS="-fPIC -I/home/developer/local/include" \
    MAGICK_LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib -L/home/developer/local/lib" \
    LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib -L/home/developer/local/lib" \
    --prefix $HOME/local \
    --enable-shared \
    --enable-portable-binary \
    --without-gcc-arch \
    --with-quantum-depth=16 \
    --without-x \
    --with-perl=$HOME/perl5/perlbrew/perls/perl-$PERL/bin/perl \
    --with-perl-options=LIB=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE

#--with-perl-options=PREFIX=/some/place". Other options accepted by MakeMaker are 'LIB', 'LIBPERL_A', 'LINKTYPE', and 'OPTIMIZE'. See the ExtUtils::MakeMaker(3) manual page for more information on configuring PERL extensions.

gmake

gmake install

#rm -rf $BUILD_DIR

export LD_LIBRARY_PATH=$HOME/local/lib
