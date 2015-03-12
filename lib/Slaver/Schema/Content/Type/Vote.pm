package Slaver::Schema::Content::Type::Vote;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'likes' => (
        is       => 'ro',
        isa      => 'Int',
        default  => sub { 0 },
        required => 0,
        writer   => 'set_likes',
        reader   => 'get_likes',
        clearer  => 'clear_likes',
);

has 'dislikes' => (
        is       => 'ro',
        isa      => 'Int',
        default  => sub { 0 },
        required => 0,
        writer   => 'set_dislikes',
        reader   => 'get_dislikes',
        clearer  => 'clear_dislikes',
);

__PACKAGE__->meta->make_immutable;
