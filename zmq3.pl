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

POE::Session->create(
    package_states => [
	main => [ qw/ _start zmqsock_registered zmqsock_recv / ],
    ]
);

sub _start {
    my ($kern, $heap) = @_[KERNEL, HEAP];

    my $zmq = POEx::ZMQ3::Sockets->new;

    $zmq->start;

    $heap->{zmq} = $zmq;

    $kern->call( $zmq->session_id, 'subscribe', 'all' );
}

sub zmqsock_registered {
    my ($kern, $heap) = @_[KERNEL, HEAP];

    my $zmq = $heap->{zmq};

    $zmq->create( 'pinger', 'REQ' );

    $zmq->connect( 'pinger', 'tcp://127.0.0.1:5050' );
    $zmq->write( 'pinger', 'PING' );
}

sub zmqsock_recv {
    my ($kern, $heap) = @_[KERNEL, HEAP];
    my ($alias, $data) = @_[ARG0 .. $#_];

    if ($data eq 'PONG') {
	printf("PONG\n");
	$zmq->write( 'pinger', 'PING' );
    }
}

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
