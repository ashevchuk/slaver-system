package Slaver::Schema::Content::Menu;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

has 'sub_id' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_sub_id');
has 'caption' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_caption');
has 'description' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_description');
has 'owner' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_owner');
has 'alias' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_alias');

has 'uri' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_uri');

has 'role' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_role');
has 'icon' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_icon');


__PACKAGE__->meta->make_immutable;
