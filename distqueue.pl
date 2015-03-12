#!/usr/bin/env perl

use MongoDB;
use MongoDBx::Queue;
use Benchmark;

my $queue = MongoDBx::Queue->new(
	database_name => "queue_global",
	collection_name => "global",
	client_options => {
		host => "mongodb://127.0.0.1:27017",
#		username => "willywonka",
#		password => "ilovechocolate",
	}
);

my $t0 = Benchmark->new;

#for (my $i = 0; $i <= 10000; $i++) {
#	$queue->add_task( { msg => "Hello World" } );
#}

my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the reserve_task took:",timestr($td),"\n";

#$queue->add_task( { msg => "Hello World" } );
#$queue->add_task( { msg => "Goodbye World" } );

my $t0 = Benchmark->new;

while ( my $task = $queue->reserve_task ) {
	print $task->{msg}, "\n";
	$queue->remove_task( $task );
}

my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the reserve_task took:",timestr($td),"\n";
