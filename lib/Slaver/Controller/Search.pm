package Slaver::Controller::Search;
use Moose;
use namespace::autoclean;

use Digest::SHA;

use Data::Dumper;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

#sub search :Local :CaptureArgs(1) {
sub index :Path :CaptureArgs(1) {
    my ($self, $c, $query) = @_;

    my $result;
    my $session_id = $c->sessionid;

    my $page = $c->stash->{page};

    $page = $c->request->params->{page} if $c->request->params->{page};

    $query = $c->request->params->{q} if $c->request->params->{q};
    $query = $c->request->params->{query} if $c->request->params->{query};

    return $c->detach( 'error_info', [ $c->loc('Empty query') ] ) unless $query;

    if ( $query ne $c->session->{data}->{search}->{query}->{request} ) {
	$page = 1;
	$c->session->{data}->{search}->{query}->{request} = $query;

	my $search_result = $c->model('Content::Search::Provider::Adaptor')->search( { query => $query, query_collection => 'content', session_id => $session_id } );

	if ( $search_result ) {
	    $c->session->{data}->{search}->{query}->{total} = $search_result->{total};
	}
    }
    else {
	$query = $c->session->{data}->{search}->{query}->{request};
    }

    my $search_results = $c->model('Content::Search::Provider::Adaptor')->fetch({
	query => $query,
	session_id => $session_id,
	    page => {
		total => $c->session->{data}->{search}->{query}->{total},
		items => $c->config->{application}->{content}->{pager}->{elements},
		current => $page
	    }
    });

    $c->stash->{pager}->total_entries( $c->session->{data}->{search}->{query}->{total} );

    $c->flash->{data}->{search} = $query;

    $c->stash(search_query => $query);

    $c->stash(title => $query);

    $c->stash(results => $search_results);
    $c->stash(template => 'templates/root/content/pages/search/results.tt2');
}

__PACKAGE__->meta->make_immutable;

1;
