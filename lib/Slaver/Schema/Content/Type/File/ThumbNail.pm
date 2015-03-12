package Slaver::Schema::Content::Type::File::ThumbNail;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has '$ref' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_ref', reader => 'get_ref');
has '$id' => (is => 'ro', isa => 'MongoDB::OID', required => 1, writer => 'set_id', reader => 'get_id');

__PACKAGE__->meta->make_immutable;
