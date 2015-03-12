#!/usr/bin/env perl

use MongoDB;
use MongoDBx::Queue;
use Benchmark;

my $queue = MongoDBx::Queue->new(
	database_name => "queue",
	collection_name => "global",
	client_options => {
		host => "mongodb://127.0.0.1:27017",
#		username => "willywonka",
#		password => "ilovechocolate",
	}
);

for (my $i = 0; $i <= 10000; $i++) {
	$queue->add_task( { msg => "Hello World", i => $i } );
}
