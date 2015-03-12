package Slaver::Model::DB;

use Moose;
BEGIN { extends 'Catalyst::Model::MongoDB' };

__PACKAGE__->config(
	schema_class => 'Slaver::Schema',
	host => '127.0.0.1',
	port => '27017',
	dbname => 'auth',
	collectionname => 'user',
	gridfs => '',
);

=head1 NAME

Slaver::Model::DB - MongoDB Catalyst model component

=head1 SYNOPSIS

See L<Slaver>.

=head1 DESCRIPTION

MongoDB Catalyst model component.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
