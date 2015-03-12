package Slaver::Schema::Content::Type::Category;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'category' => (is => 'ro', isa => 'MongoDB::OID', required => 1, writer => 'set_category', reader => 'get_category');

__PACKAGE__->meta->make_immutable;
