package Slaver::Schema::Content::Search::Last;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

use DateTime;

has 'query' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_query');

__PACKAGE__->meta->make_immutable;
