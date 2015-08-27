package Slaver::Controller::Category;
use Moose;
use namespace::autoclean;

use MongoDB::OID;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub dodie : Local {
    my ( $self, $c, $category, $action, $args ) = @_;
    return $c->test;
}

#sub root : Path('/category') CaptureArgs(3) {
sub index : Path CaptureArgs(3) {
    my ( $self, $c, $category, $action, $args ) = @_;

    my $page = $c->stash->{page};

    my $category_obj = $c->model('Content::Menu')->from_id($category);

    return $c->stash('template' => 'templates/root/content/index.tt2') unless $category_obj;

    my $result;

#    my $path_to_category = $c->model('Content::Menu')->path_to($category);

    my $db = $c->model('Data::Provider::Adaptor')->db('content');

    my $coll = $db->get_collection('menu');
    my $content = $db->get_collection('content');

    my $search_cursor = $content->find({
	"props.categories" => {
	    '$elemMatch' => {
		'$eq' => $category_obj->_id
	    }
	}
    })->limit ( $c->config->{application}->{content}->{pager}->{elements} )->skip ( ( $page -1 ) * $c->config->{application}->{content}->{pager}->{elements} );

    while (my $doc = $search_cursor->next) {
	$doc->{document_class} = $doc->{_class};
	$doc->{id_time} = $doc->{_id}->get_time;
	$doc->{id} = $doc->{_id}->value;
	push ( @{ $result->{items} }, $doc );
    }

    $c->stash->{pager}->total_entries($search_cursor->count);

    $c->stash('results', $result);

    $c->stash('category_id', $category_obj->_id->value);
#    $c->stash('category', $category_obj);
#    $c->stash('breadcrumbs', $path_to_category);

    $c->stash('template' => 'templates/root/content/pages/category/results.tt2');
}

__PACKAGE__->meta->make_immutable;

1;
