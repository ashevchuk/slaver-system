package Slaver::Schema::Content::Search::Result::Document;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has '$ref' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_ref');
has '$id' => (is => 'ro', isa => 'MongoDB::OID', required => 1, writer => 'set_id');
#has '$db' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_db');

__PACKAGE__->meta->make_immutable;
