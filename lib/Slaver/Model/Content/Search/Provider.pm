package Slaver::Model::Content::Search::Provider;
use Moose;

BEGIN { extends 'Slaver::Model::Data::Provider' }

#use Data::Dumper;

use Encode qw(encode_utf8);

use Digest::SHA;

use DateTime;

#__PACKAGE__->config(namespace => '');

__PACKAGE__->mk_accessors(qw|context|);

sub ACCEPT_CONTEXT { my ($self, $context, @args) = @_; $self->context($context); return $self; }

sub search {
    my ($self, $params) = @_;

    my $result;
    my $query = $params->{query};
    my $query_collection = $params->{query_collection};

    return $result unless $query;

    my $context = $self->context;
    my $session_id = defined $params->{session_id} ? $params->{session_id} : $context->sessionid;

    my $query_hash = Digest::SHA->new(1)->add(encode_utf8($query))->hexdigest;

    my $search_db = $self->connection->db('content');

    my $search_collection = $search_db->get_collection($query_collection);

#	{ '$sort' => { score => -1 } },

    my $search_results_collection = $search_collection->query( { '$text' => { '$search' => $query } } );

    my $search_last_collection = $search_db->get_collection('search.last');
    my $search_last_results_collection = $search_db->get_collection('search.last.results');

    my $search_issue_datetime = DateTime->now;
    my $last_search_query = $search_last_collection->find_one( { query => $query } );

    $search_last_collection->insert(
	Tie::IxHash->new(
	    _class => 'Content::Search::Last',
	    query => $query
	)
    ) if $query && !$last_search_query;

    my $search_results_collection_items_count = $search_results_collection->count;

    $result->{request} = $query;
    $result->{hash} = $query_hash;
    $result->{total} = $search_results_collection_items_count;

    return $result;
}

sub fetch {
    my ($self, $params) = @_;

    my $result;

    my $context = $self->context;
    my $session_id = defined $params->{session_id} ? $params->{session_id} : $context->sessionid;

    my $query = $params->{query};
    my $page_total = $params->{page}->{total} || 1;
    my $page_items = $params->{page}->{items} || $context->config->{application}->{content}->{pager}->{elements};
    my $page_current = $params->{page}->{current} || 1;

    my $search_db = $self->connection->db('content');

    my $search_results_collection = $search_db->get_collection("content");

    my $search_cursor = $search_results_collection->find( { '$text' => { '$search' => $query } } )->limit ( $page_items )->skip ( ( $page_current -1 ) * $page_items );

    while (my $doc = $search_cursor->next) {
	    $doc->{document_class} = $doc->{_class};
	    $doc->{id_time} = $doc->{_id}->get_time;
	    $doc->{id} = $doc->{_id}->value;
	    push ( @{ $result->{items} }, $doc );
    }

    return $result;
}

sub search_exists {
    my ($self, $params) = @_;

    my $result;
    my $query = $params->{query};
    my $query_collection = $params->{query_collection};

    return $result unless $query;

    my $context = $self->context;
    my $session_id = defined $params->{session_id} ? $params->{session_id} : $context->sessionid;

    my $query_hash = Digest::SHA->new(1)->add(encode_utf8($query))->hexdigest;

    my $search_db = $context->model('Data::Provider')->db('content');

    my $search_collection = $search_db->get_collection($query_collection);

#	{ '$sort' => { score => -1 } },

    $search_collection->aggregate([
	{ '$match' => { '$text' => { '$search' => $query } } },
	{ '$out' => "tmp.search.results." . $session_id }
    ]);

    my $search_last_collection = $search_db->get_collection('search.last');
    my $search_last_results_collection = $search_db->get_collection('search.last.results');

    my $search_issue_datetime = DateTime->now;
    my $last_search_query = $search_last_collection->find_one( { query => $query } );

    $search_last_collection->insert(
	Tie::IxHash->new(
	    _class => 'Content::Search::Last',
	    query => $query
	)
    ) if $query && !$last_search_query;

    my $search_results_collection = $search_db->get_collection("tmp.search.results." . $session_id);
    my $search_results_collection_items_count = $search_results_collection->count;

    $search_last_results_collection->insert(
	Tie::IxHash->new(
	    database => "content",
	    collection => "tmp.search.results." . $session_id,
	    session => $session_id,
	    query => $query,
	    query_hash => $query_hash,
	    issue => $search_issue_datetime,
	    items => $search_results_collection_items_count,
	    removed => 0
	)
    );

    $result->{request} = $query;
    $result->{hash} = $query_hash;
    $result->{total} = $search_results_collection_items_count;

    return $result;
}

sub fetch_exists {
    my ($self, $params) = @_;

    my $result;

    my $context = $self->context;
    my $session_id = defined $params->{session_id} ? $params->{session_id} : $context->sessionid;

    my $query = $params->{query};
    my $page_total = $params->{page}->{total} || 1;
    my $page_items = $params->{page}->{items} || $context->config->{application}->{content}->{pager}->{elements};
    my $page_current = $params->{page}->{current} || 1;

    my $search_db = $context->model('Data::Provider')->db('content');

    my $search_results_collection = $search_db->get_collection("tmp.search.results." . $session_id);

    my $search_cursor = $search_results_collection->find( { } )->limit ( $page_items )->skip ( ( $page_current -1 ) * $page_items );

    while (my $doc = $search_cursor->next) {
	    $doc->{document_class} = $doc->{_class};
	    $doc->{id_time} = $doc->{_id}->get_time;
	    $doc->{id} = $doc->{_id}->value;
	    push ( @{ $result->{items} }, $doc );
    }

    return $result;
}

__PACKAGE__->meta->make_immutable;

1;
