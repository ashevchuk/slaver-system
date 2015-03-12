#!/usr/bin/env perl

use MongoDB;
use MongoDB::GridFS;
use MongoDB::GridFS::File;


my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'foo' );

my $grid = $database->get_gridfs;
my $fh = IO::File->new("infile.bin", "r");
my $id = $grid->insert($fh, {"filename" => "infile.bin"});

my $outfile = IO::File->new("outfile.bin", "w");
my $file = $grid->find_one;
$file->print($outfile);

#$grid->delete($id);