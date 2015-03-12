#!/usr/bin/env perl

use MongoDB;
use MongoDB::GridFS;
use MongoDB::GridFS::File;

BEGIN { $ENV{ PERL_ZMQ_BACKEND } = 'ZMQ::LibZMQ3'; }
use ZMQ;

use POE;
use POEx::ZMQ3;
use POEx::ZMQ3::Sockets;

## A POEx::ZMQ3::Sockets instance:
#my $zmq = POEx::ZMQ3->new;

use POE;

my $zrep = POEx::ZMQ3::Replier->new;

POE::Session->create(
    inline_states => {
	_start => sub {
	    $zrep->start( 'tcp://127.0.0.1:5665' );
	    $_[KERNEL]->post( $zrep->session_id, 'subscribe', 'all', );
	},

	zeromq_replying_on => sub {
	    my $endpoint = $_[ARG0];
	    print "Waiting for requests on $endpoint\n";
	},

	zeromq_got_request => sub {
	    my $data = $_[ARG0];
	    $zrep->reply("PONG")
	},
    }
);

$poe_kernel->run;

#my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
#my $database   = $client->get_database( 'foo' );

#my $grid = $database->get_gridfs;
#my $fh = IO::File->new("infile.bin", "r");
#my $id = $grid->insert($fh, {"filename" => "infile.bin"});

#my $outfile = IO::File->new("outfile.bin", "w");
#my $file = $grid->find_one;
#$file->print($outfile);

#$grid->delete($id);
