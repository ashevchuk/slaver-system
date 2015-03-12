package Slaver::Schema::Content::Type::Tag;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'tag' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_tag', reader => 'get_tag');

__PACKAGE__->meta->make_immutable;
