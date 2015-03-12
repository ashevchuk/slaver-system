package Slaver::Controller::Sitemap;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use WWW::Sitemap::XML;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub xml :Local {
    my ($self, $c) = @_;

    my $map = WWW::Sitemap::XML->new();
    my $db = $c->model('Data::Provider::Adaptor')->db('content');
    my $collection = $db->get_collection('menu');

    my $cursor = $collection->find( { } );

    while (my $doc = $cursor->next) {
	next if defined $doc->{uri} && $doc->{uri} eq "/";
	my $loc = defined $doc->{uri} ? sprintf("%s/%s/", $c->config->{application}->{url}, $doc->{uri}) : sprintf("%s/%s/%s/", $c->config->{application}->{url}, $doc->{role}, $doc->{alias});

	$map->add(
	    loc => $loc,
#	    lastmod => '2010-11-22',
	    changefreq => 'weekly',
	    priority => 1.0,
	);
    }

    my $xml = $map->as_xml;

    return $c->response->body( $xml->toString( 1 ) );
}

__PACKAGE__->meta->make_immutable;

1;
