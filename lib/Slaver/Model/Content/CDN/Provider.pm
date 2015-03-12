package Slaver::Model::Content::CDN::Provider;
use Moose;

BEGIN { extends 'Catalyst::Model' }

use Data::Dumper;

use Encode qw(encode_utf8);

use Digest::SHA;

use Data::Page;

use DateTime;

#__PACKAGE__->config(namespace => '');

__PACKAGE__->mk_accessors(qw|context|);

sub ACCEPT_CONTEXT { my ($self, $context, @args) = @_; $self->context($context); return $self; }

sub get_cluster_hosts {
    my ($self, $params) = @_;

    my $context = $self->context;

    my $blackboard_db = $context->model('Data::Provider')->db('blackboard');

    my $stats_coll = $blackboard_db->get_collection('host.sys.stats');
    my $stats = $stats_coll->find( { } );

    my $hosts = [ ];

    while ( my $stat = $stats->next ) {
	push @{ $hosts }, $stat->{host};
    }

    return $hosts;
}

__PACKAGE__->meta->make_immutable;

1;
