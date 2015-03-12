#!/usr/bin/env perl

use strict;
use warnings;

use MongoDB;

my $drop_all = 0;

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $auth_database   = $client->get_database('auth');
my $content_database   = $client->get_database('content');

if ( $drop_all ) {
    my @collections = $content_database->collection_names;
    foreach my $coll ( @collections ) {
	if ( $coll =~ m/^tmp/ ) {
	    printf("Drop %s collection\n", $coll);
	    my $collection = $content_database->get_collection($coll);
	    $collection->drop;
	}
    }

    exit 0;
}

my $sessions_collection = $auth_database->get_collection('sessions');
my $search_last_results_collection = $content_database->get_collection('search.last.results');

my $search_last_results_cursor = $search_last_results_collection->find( { } );

while ( my $search_last_result = $search_last_results_cursor->next ) {
    my $sessions_cursor = $sessions_collection->find( { _id => $search_last_result->{session} } );
    if ( $sessions_cursor->count > 0 ) {
	printf("Drop %s.%s collection\n", $search_last_result->{database}, $search_last_result->{collection});
	my $database = $client->get_database($search_last_result->{database});
	my $collection = $database->get_collection($search_last_result->{collection});
	$collection->drop;
	$search_last_results_collection->remove( { session => $search_last_result->{session} } );
    }
}
