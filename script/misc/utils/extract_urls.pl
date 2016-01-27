#!/usr/bin/env perl

use strict;
use warnings;

use Nginx::ParseLog;

use Getopt::Long;
use Pod::Usage;

use AnyEvent;
use AnyEvent::Handle;

use DateTime;
use DateTime::Format::Strptime;

use MongoDB;

use Data::Dumper;

my $log;
my $timeout;
my $verbose;
my $host;

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'log' );
my $collection = $database->get_collection('access.uri');

my $cursor = $collection->find( { } );

open my $fh, ">", "urls.log" or die;

while ( my $doc = $cursor->next ) {
    print $fh $doc->{uri} . "\n";
}

close $fh;
