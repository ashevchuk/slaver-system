#!/usr/bin/env perl

use MongoDBx::Queue;
use ZMQx::Class;
use AnyEvent;
use JSON::XS;

my $queue = MongoDBx::Queue->new(
	database_name => "queue",
	collection_name => "global",
	client_options => {
		host => "mongodb://127.0.0.1:27017",
#		username => "willywonka",
#		password => "ilovechocolate",
	}
);

my $subscriber = ZMQx::Class->socket( 'SUB', connect => 'tcp://localhost:10000' );
$subscriber->subscribe('1');

my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

my $watcher = $subscriber->anyevent_watcher(sub {
	while ( my $msg = $subscriber->receive ) {
		my $data = $coder->decode($msg->[1]);
		$queue->add_task( $data );
	}
});

AnyEvent->condvar->recv;
