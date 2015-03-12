package Slaver::Schema::Content::Type::Votes;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';
use DateTime;

has 'session' => (is => 'ro', isa => 'Str', required => 1);
has 'document' => (is => 'ro', isa => 'MongoDB::OID', required => 1);
has 'mark' => (is => 'ro', isa => 'Str', required => 1);
has 'issue' => (is => 'ro', isa => 'DateTime', required => 1, default => sub { DateTime->now() } );

__PACKAGE__->meta->make_immutable;
