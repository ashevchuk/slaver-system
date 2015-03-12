package Slaver::Controller::Sys::Stats;
use Moose;
use namespace::autoclean;

use Data::Page;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $stats = [ ];

    my $db = $c->model('Data::Provider')->db('blackboard');

    my $stats_coll = $db->get_collection('host.sys.stats');
    my $stats_curr = $stats_coll->find({ }, { sort_by => [ host => 1 ] });
    while ( my $stat = $stats_curr->next ) {
	push @{ $stats }, $stat;
    }

    $c->stash( stats => $stats );
    $c->stash( template => 'templates/root/content/pages/sys/stats.tt2' );
}

__PACKAGE__->meta->make_immutable;

1;
