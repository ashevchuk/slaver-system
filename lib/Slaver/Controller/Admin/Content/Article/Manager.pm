package Slaver::Controller::Admin::Content::Article::Manager;
use Moose;
use namespace::autoclean;

use Data::Dumper qw (Dumper);
use Data::Page;

use MongoDB::OID;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

sub trim : Private {
    my @out = @_;
    for (@out) { s/^\s+//; s/\s+$//; }
    return wantarray ? @out : $out[0];
}

sub create : Local {
    my ( $self, $c ) = @_;

#    my $category_obj = $c->model('Content::Menu')->from_id($c, $category);
#    return $c->stash('template' => 'templates/root/content/index.tt2') unless $category_obj;
#    my $path_to_category = $c->model('Content::Menu')->path_to($c, $category);
#    my $db = $c->model('Data::Provider')->db('content');
#    my $content = $db->get_collection('content');
#    $c->log->debug("Items:" . $search_cursor->count);

    my $body = $c->request->body_data;

#    $c->log->debug("Body:", Dumper($body));

    my $tags = [ ];
    foreach my $tag ( split ( ",", $body->{tags} ) ) {
	$tag =~ s/^[\s*?|\s*?]$//sg;
	push @{ $tags }, trim($tag);
    }


    my $db_content = $c->model('Data::Provider')->db('content');

    my $content_collection = $db_content->get_collection('content');

    my $content_id = $content_collection->insert({
	_class => "Content::Type::Article",
	props => {
	    caption => $body->{title},
	    description => $body->{description},
	    length => length $body->{content},
	    body => $body->{content},
	    roles => [
		"content"
	    ],
	    owner => $c->user_exists() ? MongoDB::OID->new(value => $c->session->{__user}) : MongoDB::OID->new(value => 0),
	    related => [
	    ],
	    categories => [
		MongoDB::OID->new(value => "514c2e7c08e4a52d1f000009")
	    ],
	    tags => $tags
	}
    });

    $c->stash->{ok} = 1;

    $c->forward('View::JSON');
}

__PACKAGE__->meta->make_immutable;

1;
