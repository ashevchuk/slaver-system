#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use MongoDB;
use MongoDB::GridFS;
use MongoDB::GridFS::File;

use MongoDBx::Queue;

use Data::Dumper;
use Sys::Hostname;

use File::Basename;
use File::Copy;
use File::Temp;

my $hostname = hostname;

my $queue = MongoDBx::Queue->new(
    database_name => "queue",
    collection_name => "service.image.convert",
    client_options => {
	host => "mongodb://localhost:27017"
    }
);

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'data' );
my $content_database   = $client->get_database('content');
my $content_collection = $content_database->get_collection('content');
my $files_cursor = $content_collection->find( { "_class" => "Content::Type::File", "props.thumbnails" => [ ] } );
my $grid = $database->get_gridfs;

while ( my $file = $files_cursor->next ) {
    my ( $filename, $dirs, $suffix ) = fileparse( $file->{props}->{caption}, qr/\.[^.]*/ );

    my $temp_file = File::Temp::tempnam( "/tmp", "upload_" );
    $temp_file .= $suffix;

    printf("Using file %s\n",  $file->{props}->{caption});

    my $grid_file = $grid->get( $file->{props}->{locations}->[0]->{id} );

    eval {
	$content_collection->remove({_id => $file->{_id}}) unless $grid_file;
	$grid->delete( $file->{props}->{locations}->[0]->{id} ) unless $grid_file;
    };

    printf("not found...\n") unless $grid_file;
    next unless $grid_file;

    my $out_file = IO::File->new( $temp_file, "w" );
    $grid_file->print( $out_file );
    $out_file->close;

    my $convert_task = {
	file_name => $temp_file,
	extension => $suffix,
	file_id => $file->{props}->{locations}->[0]->{id}->to_string,
	convert_to => "png",
	content_file_id => $file->{_id}->to_string,
	mime => $file->{props}->{mime_type},
	media_type => $file->{props}->{media_type},
	media_sub_type => $file->{props}->{media_sub_type},
	tmp => "/tmp",
	remove => 1,
	issue => DateTime->now(),
	host => $hostname
    };

    printf("%s\n", $file->{props}->{caption});

    $queue->add_task($convert_task);
}
