#!/bin/bash

wget -O - http://install.perlbrew.pl | bash

echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bash_profile

cd ~/

. .bashrc

perlbrew install-cpanm
perlbrew install --force --thread --multi --64int --64all --ld --clang --notest -Accflags='-fPIC' perl-5.18.1 -D useshrplib
perlbrew switch perl-5.18.1
