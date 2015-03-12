#!/usr/bin/env perl

use strict;
use warnings;

use ZMQx::Class;
use JSON::XS;
use MongoDBx::Queue;

my $queue = MongoDBx::Queue->new(
	database_name => "queue",
	collection_name => "global",
	client_options => {
		host => "mongodb://127.0.0.1:27017",
#		username => "willywonka",
#		password => "ilovechocolate",
	}
);

my $publisher = ZMQx::Class->socket( 'PUB', bind => 'tcp://*:10000' );

my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

while ( 1 ) {
	while ( my $task = $queue->reserve_task ) {
		$queue->remove_task($task);

		delete $task->{_id};
		my $json = $coder->encode ($task);
		$publisher->send( [ 1, $json ] );
	}
	select( undef, undef, undef, 0.1);
}
