package Slaver::Controller::Admin::System::Log;
use Moose;
use namespace::autoclean;

use Data::Dumper qw(Dumper);
use MongoDB::OID;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

sub show : Local : CaptureArgs(6) {
    my ( $self, $c ) = @_;

    return $c->detach( '/access_denied' ) unless $c->check_any_user_role( qw/admin/ );

    my $result;

    my $page = $c->stash->{page};

    my %args = @{ $c->request->arguments };

    if ( $args{text} ) {
	$args{text} =~ s/\s/\./sg;
	$args{text} = { '$regex' => $args{text}, '$options' => "mix" };
    }

    $c->log->debug("Query:", Dumper(\%args));

    my $db = $c->model('Data::Provider')->db('log');

    my $log = $db->get_collection('slaver');

    my $search_cursor = $log->find(\%args)->limit ( $c->config->{application}->{content}->{pager}->{elements} )->skip ( ( $page -1 ) * $c->config->{application}->{content}->{pager}->{elements} );

    while (my $doc = $search_cursor->next) {
	$doc->{id_time} = $doc->{_id}->get_time;
	$doc->{id} = $doc->{_id}->value;
	push ( @{ $result->{items} }, $doc );
    }

    $c->stash->{pager}->total_entries($search_cursor->count);

    $c->stash('results', $result);

    $c->stash( template => 'templates/root/content/pages/admin/system/log/index.tt2' );
}

__PACKAGE__->meta->make_immutable;

1;
