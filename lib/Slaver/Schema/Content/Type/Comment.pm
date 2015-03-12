package Slaver::Schema::Content::Type::Comment;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'owner' => (is => 'ro', isa => 'MongoDB::OID', required => 0, writer => 'set_owner', reader => 'get_owner');
has 'caption' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_caption', reader => 'get_caption');
has 'text' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_text', reader => 'get_text');
has 'issue' => (is => 'ro', isa => 'DateTime', required => 1, default => sub { DateTime->now() } );

__PACKAGE__->meta->make_immutable;
