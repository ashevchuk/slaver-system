#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use DateTime;
use MongoDB;
use Digest::MD5 qw(md5_hex);
#use AnyEvent;
use Sys::Statistics::Linux;
use Linux::Proc::Net::TCP;

use Net::WebSocket::EV;
use HTTP::Server::EV;
use Digest::SHA1 qw(sha1_base64);

use Daemon::Generic;

our $json = JSON->new->utf8(1)->allow_nonref->allow_blessed;

use AnyEvent;
use AnyEvent::Timer::Cron;

my $w; $w = AnyEvent::Timer::Cron->new(cron => '* * * * *', cb => sub {
    print "event\n"
});

AnyEvent->condvar->recv;
