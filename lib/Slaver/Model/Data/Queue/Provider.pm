package Slaver::Model::Data::Queue::Provider;

use MongoDB;
use MongoDB::OID;

use MongoDBx::Queue;

use MongoDBx::Class::ConnectionPool;
use MongoDBx::Class;
use Moose;

BEGIN { extends 'Catalyst::Model' }

our $VERSION = '0.06';

has host            => ( isa => 'Str', is => 'ro', required => 1, default => sub { 'localhost' } );
has port            => ( isa => 'Int', is => 'ro', required => 1, default => sub { 27017 } );
has database_name   => ( isa => 'Str', is => 'ro', required => 1, default => sub { 'queue' } );
has collection_name => ( isa => 'Str', is => 'ro', required => 1, default => sub { 'global' } );
has username        => ( isa => 'Str', is => 'ro', required => 0 );
has password        => ( isa => 'Str', is => 'ro', required => 0 );

has 'queue' => (
  isa => 'HashRef[MongoDBx::Queue]',
  is => 'rw',
  default => sub { { } },
  lazy_build => 0
);

sub _build_queue {
    my ($self) = @_;
    #$self->queue = { };

    return $self->queue;
}

sub get_queue {
    my ($self, $queue_name) = @_;

    if ( !$self->queue->{$queue_name} ) {

	my $client_options = {
	    host => sprintf("mongodb://%s:%s", $self->host, $self->port)
	};

	$client_options->{username} = $self->username if defined $self->username;
	$client_options->{password} = $self->password if defined $self->password;

	$self->queue->{$queue_name} = MongoDBx::Queue->new(
	    database_name => $self->database_name,
	    collection_name => defined $queue_name ? $queue_name : $self->collection_name,
	    client_options => $client_options
	);
    }

  return $self->queue->{$queue_name};
}

1;
