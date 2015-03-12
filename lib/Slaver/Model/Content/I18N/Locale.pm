package Slaver::Model::Content::I18N::Locale;
use Moose;

BEGIN { extends 'Catalyst::Model' }

use Data::Dumper;

#__PACKAGE__->config(namespace => '');

#sub ACCEPT_CONTEXT { shift }

sub localize {
    my ($self, $context) = @_;

    my $db = $context->model('Data::Provider')->db('content');
    my $coll = $db->get_collection('i18n.locale');

    my $result = $coll->find();

    return $result;
}

__PACKAGE__->meta->make_immutable;

1;
