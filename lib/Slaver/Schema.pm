package Slaver::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use namespace::autoclean;
#extends 'DBIx::Class::Schema';
BEGIN { extends 'Catalyst::Model::MongoDB' };

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-30 18:09:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0eebDopG0RPImUoVlRBhTg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
