package Slaver::Schema::Auth::Users;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

has 'username' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_username');
has 'name' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_name');
has 'password' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_password');

has 'avatar' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_avatar');

has 'roles' => (
        is        => 'ro',
        isa       => 'ArrayRef',
        traits    => ['Array'],
        default   => sub { [] },
        required  => 0,
        predicate => 'has_role',
        writer    => 'set_role',
        reader    => 'get_role',
        clearer   => 'clear_role',
        handles   => {
                all_roles    => 'elements',
                add_role     => 'push',
                map_roles    => 'map',
                filter_roles => 'grep',
                find_role    => 'first',
                join_role    => 'join',
                count_role   => 'count',
                has_no_roles => 'is_empty',
                sorted_roles => 'sort'
        }
);

__PACKAGE__->meta->make_immutable;
