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
CFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib -L/home/developer/local/lib"
PKG_CONFIG_PATH="${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE"
PKG_CONFIG_LIBDIR="${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE"

export CPPFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE"
export LDFLAGS="-fPIC -L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE -L/usr/local/lib -L/home/developer/local/lib"
export PKG_CONFIG_PATH="${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE"
export PKG_CONFIG_LIBDIR="${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE"

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
    --disable-openmp \
    --with-sysroot=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    --with-perl=$HOME/perl5/perlbrew/perls/perl-$PERL/bin/perl \
    --with-perl-options="LIB=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    PERL_INC=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    PERL_LIB=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    LDDLFLAGS=-L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    CCFLAGS=-L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    CCDLAGS=-L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    CCCDLAGS=-L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    INC=-L${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE \
    LIBS=${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE" \

#--with-perl-options=PREFIX=/some/place". Other options accepted by MakeMaker are 'LIB', 'LIBPERL_A', 'LINKTYPE', and 'OPTIMIZE'. See the ExtUtils::MakeMaker(3) manual page for more information on configuring PERL extensions.

mkdir $BUILD_DIR/ImageMagick-$IMAGE_MAGICK/magick/.libs

ln -s ${HOME}/perl5/perlbrew/perls/perl-${PERL}/lib/${PERL}/amd64-freebsd-thread-multi-ld/CORE/libperl.so $BUILD_DIR/ImageMagick-$IMAGE_MAGICK/magick/.libs/libperl.so

gmake V=1 all perl-build 

gmake install

#rm -rf $BUILD_DIR

export LD_LIBRARY_PATH=$HOME/local/lib
