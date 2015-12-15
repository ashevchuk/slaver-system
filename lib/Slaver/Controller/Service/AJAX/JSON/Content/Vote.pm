package Slaver::Controller::Service::AJAX::JSON::Content::Vote;

use Moose;
use namespace::autoclean;

use DateTime;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

sub mark :Local {
    my ( $self, $c ) = @_;

    my $body = $c->request->body_data;

    return $c->response->body(q({"error": true})) unless $body->{vote} || $body->{document_id};

    my $db = $c->model('Data::Provider')->db('content');

    my $content = $db->get_collection('content');
    my $votes = $db->get_collection('votes');

    my $vote_inc = 1;
    my $vote_field = $body->{vote} > 0 ? "likes" : "dislikes";

    my $vote_issue_key = sprintf("session:vote:%s:doc%s", $c->sessionid, $body->{document_id});

    my $vote_issue = $c->cache->get($vote_issue_key);

#    my $vote_issue = $votes->find_one({
#	session => $c->sessionid,
#	document => MongoDB::OID->new( value => $body->{document_id} ),
#    });

    if ( $vote_issue ) {
	if ( $vote_issue->{mark} eq $vote_field ) {
	    $vote_inc = -1;
#	    $vote_issue->remove;
	    $c->cache->remove($vote_issue_key);
	}
	else {
	    $vote_inc = 0;
	}
    }

#    $votes->insert({
#	session => $c->sessionid,
#	document => MongoDB::OID->new( value => $body->{document_id} ),
#	mark => $vote_field,
#	issue => DateTime->now,
#	_class => "Content::Type::Votes"
#    }) if $vote_inc > 0;

    $c->cache->set($vote_issue_key, {
	session => $c->sessionid,
	document => $body->{document_id},
	mark => $vote_field,
	issue => DateTime->now->epoch,
    }, 60*60*24*1) if $vote_inc > 0;

    my $document = $content->find_and_modify({
	query => { '_id' => MongoDB::OID->new( value => $body->{document_id} ) },
	update => { '$inc' => { 'props.votes.' . $vote_field => $vote_inc } },
	new => 1
    });

#    $c->stash->{session} = $c->sessionid;

    $c->stash->{likes} = $document->{props}->{votes}->{likes} || 0;
    $c->stash->{dislikes} = $document->{props}->{votes}->{dislikes} || 0;
    $c->stash->{document_id} = $body->{document_id};
#
    $c->forward('View::JSON');
}

__PACKAGE__->meta->make_immutable;

1;
