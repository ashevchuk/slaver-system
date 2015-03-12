#!/bin/bash

CPU_CORES_NUM=$(nproc)
PERL_VERSION=perl-5.20.2

perlbrew install --force --noman --thread --multi --64int --64all --ld --clang --notest -Accflags='-fPIC' $PERL_VERSION -D useshrplib -j $CPU_CORES_NUM
perlbrew switch $PERL_VERSION
#perlbrew uninstall perl-5.18.1
