package Slaver::Controller::Cache::Data;
use Moose;
use namespace::autoclean;

use IO::File;
use File::Basename;
use MongoDB::OID;

use utf8;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

sub files : Local CaptureArgs(2) {
    my ( $self, $c, $file_id, $file_name ) = @_;

    my $cached_file_name = $c->config->{application}->{data}->{cache}->{directory} . "/" . $file_id;

    unless ( -e $cached_file_name ) {
	my $db = $c->model('Data::Provider')->db('data');
	my $grid = $db->get_gridfs;

        my $outfile = IO::File->new($cached_file_name, "w");
	my $file = $grid->find_one( { _id => MongoDB::OID->new( value => $file_id ) } );
	$file->print($outfile);
	$outfile->close;
    }

    $c->response->redirect("/cache/data/files/" . $file_id ."/" . $file_name);
}

__PACKAGE__->meta->make_immutable;

1;
