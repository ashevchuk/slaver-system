package Slaver::Schema::Content::Type::File;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

holds_one 'props' => (is => 'ro', isa => 'Slaver::Schema::Content::Type::File::Props', required => 1, writer => 'set_props', reader => 'get_props');

__PACKAGE__->meta->make_immutable;
