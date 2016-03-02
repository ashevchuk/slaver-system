package Slaver::Controller::Service::AJAX::JSON::Content::Comment;

use Moose;
use namespace::autoclean;

use DateTime;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

sub add :Local {
    my ( $self, $c ) = @_;

    my $body = $c->request->body_data;

    return $c->response->body(q({"error": true})) unless $body->{message} || $body->{document_id};

    my $db = $c->model('Data::Provider')->db('content');

    my $content = $db->get_collection('content');

#    my $document = $content->find_one( { '_id' => MongoDB::OID->new( value => $body->{document_id} ) } );

    my $document = $content->find_and_modify({
        query => { '_id' => MongoDB::OID->new( value => $body->{document_id} ) },
        update => { '$push' => { 'props.comments' => { issue => DateTime->now, text => $body->{message} } } },
        new => 1
    });

#    if ( $document->get_props->has_comments ) {
#	$document->get_props->get_comments->add_comment({ issue => DateTime->now, text => $body->{message}, _class => 'Content::Type::Comment' });
#    }
#    else {
#	$document->get_props->set_comments([{ issue => DateTime->now, text => $body->{message}, _class => 'Content::Type::Comment' }]);
#    }

#    $c->stash->{session} = $c->sessionid;

    $c->stash->{comment} = $body;
#
    $c->forward('View::JSON');
}

sub load :Path :CaptureArgs(1) {
    my ( $self, $c, $document_id ) = @_;

    return $c->response->body(q({"error": true})) unless $document_id;

    my $db = $c->model('Data::Provider')->db('content');

    my $content = $db->get_collection('content');

    my $document = $content->find_one( { '_id' => MongoDB::OID->new( value => $document_id ) } );

#    $c->stash->{session} = $c->sessionid;

    $c->stash->{comments} = $document->get_props->get_comments;
    $c->stash( template => 'templates/root/comments_panel.tt2' );
    $c->forward('View::HTML');
}

__PACKAGE__->meta->make_immutable;

1;
