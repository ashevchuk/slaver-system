#!/usr/bin/env perl

use strict;
use warnings;

use VCI;

my $repository = VCI->connect(type => 'Hg', repo => 'http://hgweb.example.com/');
