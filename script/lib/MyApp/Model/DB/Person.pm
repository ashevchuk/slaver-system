package MyApp::Model::DB::Person;

use MongoDBx::Class::Moose;
use namespace::autoclean;

with 'MongoDBx::Class::Document';

has 'first_name' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_first_name');
has 'middle_name' => (is => 'ro', isa => 'Str', predicate => 'has_middle_name', writer => 'set_middle_name');
has 'last_name' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_last_name');

__PACKAGE__->meta->make_immutable;
