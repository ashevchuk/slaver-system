package Slaver::Controller::Content;
use Moose;
use namespace::autoclean;

use MongoDB::OID;
use Data::Dumper;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

#sub root : Path('/content') CaptureArgs(0) {
sub index : Path CaptureArgs(1) {
#    my ( $self, $c, $category, $action, $args ) = @_;
    my ( $self, $c, $item ) = @_;

    if ( scalar @{ $c->request->arguments } == 1 ) {
	return $self->item($c, $item);
    }

    my $page = $c->stash->{page};

    my $template_path;
    my $template_index;

#    $c->log->debug('Args: ', Data::Dumper->Dump([$c->request->arguments]));

    my $template_root = $c->config->{root} . $c->config->{application}->{content}->{path_separator};

    $template_path = $c->config->{application}->{content}->{template}->{root} .
	$c->config->{application}->{content}->{path_separator} .
	$c->request->path;

    $template_path =~ s{/$}{}g;

    if(-d $template_root . $template_path) {
	$template_index = sprintf("%s%s%s.%s",
	    $template_path,
	    $c->config->{application}->{content}->{path_separator},
	    $c->config->{application}->{content}->{template}->{index},
	    $c->config->{application}->{content}->{template}->{extension}
	);
    }

    if (-e $template_root . $template_index) {

    } else {
	$template_index = sprintf("%s.%s",
	    $template_path,
	    $c->config->{application}->{content}->{template}->{extension}
	);
    }

#    $c->log->debug('Using template: ' . $template_index);
#    $c->log->debug('Using template path: ' . $template_path);
#    $c->stash('content' => $template_index);
#    $c->stash('include_templates' => [ $template_index ]);
    $c->stash('template' => $template_index);
#    $c->stash('template' => 'templates/root/index.tt2');
}

sub item : Private {
    my ( $self, $c, $item ) = @_;

    return $c->stash('template' => 'templates/root/index.tt2') unless $item;

    my $page = $c->stash->{page};

    my $db = $c->model('Data::Provider::Adaptor')->db('content');

    my $coll = $db->get_collection('menu');
    my $content = $db->get_collection('content');

    my $result;

    my $search_cursor = $content->find({
	'$or' => [
	    { '_id' => MongoDB::OID->new( value => $item ) },
	    { 'props.shortcut' => $item }
	]
    });

    while (my $doc = $search_cursor->next) {
        $doc->{document_class} = $doc->{_class};
        $doc->{id_time} = $doc->{_id}->get_time;
        $doc->{id} = $doc->{_id}->value;

	if ( exists $doc->{props}->{categories} ) {
	    if ( scalar @{ $doc->{props}->{categories} } ) {
		my $category = $doc->{props}->{categories}->[0];
		my $path_to_category = $c->model('Content::Menu')->path_to_by_id($category);
		my $category_obj = $c->model('Content::Menu')->by_id($category);
		$c->stash('category_id', $category_obj->_id->value);
#		$c->stash('category', $category_obj);
		$c->stash('breadcrumbs', $path_to_category);
	    }
	}

        push ( @{ $result->{items} }, $doc );
    }

    $c->stash('results', $result);

    $c->stash('template' => 'templates/root/content/pages/category/results.tt2');
}

__PACKAGE__->meta->make_immutable;

1;
