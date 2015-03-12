package Slaver::Schema::Content::Role;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'role' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_role');

__PACKAGE__->meta->make_immutable;
