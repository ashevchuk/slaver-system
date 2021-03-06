package Slaver::Model::Data::Provider;
# ABSTRACT: MongoDB model class for Catalyst
use MongoDB;
use MongoDB::OID;

$MongoDB::Cursor::timeout = 60000;

use MongoDBx::Class;
use MongoDBx::Class::ConnectionPool;

use Moose;

BEGIN { extends 'Catalyst::Model' }

our $VERSION = '0.06';

has host           => ( isa => 'Str', is => 'ro', required => 1, default => sub { '127.0.0.1' } );
has port           => ( isa => 'Int', is => 'ro', required => 1, default => sub { 27017 } );
has dbname         => ( isa => 'Str', is => 'ro' );
has collectionname => ( isa => 'Str', is => 'ro' );
has gridfsname     => ( isa => 'Str', is => 'ro' );

sub new {
    my ($class, $config, $app) = @_;
	
    my $self = {
	config => $config
    };

    bless $self, $class;
}

has 'connection' => (
  isa => 'MongoDBx::Class::Connection',
  is => 'rw',
  lazy_build => 1,
);

sub _build_connection {
  my ($self) = @_;
  $self->{dbx} = MongoDBx::Class->new(namespace => 'Slaver::Schema', search_dirs => ['lib/Slaver/Schema'])
    unless defined $self->{dbx};

  $self->{pool} = $self->{dbx}->pool(max_conns => 32, type => 'rotated', params => {
	host => "127.0.0.1", #$self->{config}->{host},
	port => "27017", #$self->{config}->{port},
	auto_reconnect => 1,
	auto_connect => 1,
  }) unless defined $self->{pool};

  $self->{pool}->return_conn($self->{dbx_connection}) if defined $self->{dbx_connection};

  return $self->{dbx_connection} = $self->{pool}->get_conn;

    $self->{dbx_connection} = $self->{dbx}->connect(
    host => "127.0.0.1", #$self->{config}->{host},
    port => "27017", #$self->{config}->{port},
    wtimeout => 10000,
    auto_reconnect => 1,
    auto_connect => 1,
    timeout => 60000,
    query_timeout => 60000
  ) unless defined $self->{dbx_connection};

  return $self->{dbx_connection};
}

has 'dbs' => (
  isa => 'HashRef[MongoDBx::Class::Database]',
  is => 'rw',
  default => sub {{}},
);

sub get_database {
  my ($self, $dbname) = @_;
  return $self->connection->get_database($dbname);
}

sub db {
  my ( $self, $dbname ) = @_;
  $dbname = $self->dbname if !$dbname;
  confess "no dbname given via parameter or config" if !$dbname;
  return $self->connection->get_database($dbname);
#  if (!$self->dbs->{$dbname}) {
#    $self->dbs->{$dbname} = $self->connection->get_database($dbname);
# }
#  return $self->dbs->{$dbname};
}

sub c { shift->collection(@_) }
sub coll { shift->collection(@_) }
sub collection {
  my ( $self, $param ) = @_;
  my $dbname;
  my $collname;
  my @params = split(/\./,$param);
  if (@params > 1) {
	$dbname = $params[0];
	$collname = $params[1];
  } else {
    $dbname = $self->dbname;
	if (@params == 1) {
      $collname = $params[0];
	} else {
      $collname = $self->collectionname;
	}
  }
  confess "no dbname given via parameter or config" if !$dbname;
  confess "no collectionname given via parameter or config" if !$collname;
  $self->db($dbname)->get_collection($collname);
}

sub run {
  my ( $self, @params ) = @_;
  confess "no dbname given via config" if !$self->dbname;
  $self->db->run_command(@params);
}

sub eval {
  my ( $self, @params ) = @_;
  confess "no dbname given via config" if !$self->dbname;
  $self->db->eval(@params);
}

sub collnames { shift->collection_names(@_) }
sub collection_names {
  my ( $self, @params ) = @_;
  confess "no dbname given via config" if !$self->dbname;
  $self->db->collection_names(@params);
}

sub g { shift->gridfs(@_) }
sub gridfs {
  my ( $self, $param ) = @_;
  my $dbname;
  my $gridfsname;
  my @params = split(/\./,$param);
  if (@params > 1) {
	$dbname = $params[0];
	$gridfsname = $params[1];
  } else {
    $dbname = $self->dbname;
	if (@params == 1) {
      $gridfsname = $params[0];
	} else {
      $gridfsname = $self->gridfsname;
	}
  }
  confess "no dbname given via parameter or config" if !$dbname;
  confess "no gridfsname given via parameter or config" if !$gridfsname;
  $self->db($dbname)->get_gridfs($gridfsname);
}

sub dbnames { shift->database_names(@_) }
sub database_names {
  my ( $self ) = @_;
  $self->connection->database_names;
}

sub oid {
  my( $self, $_id ) = @_;
  return MongoDB::OID->new( value => $_id );
}

1;


__END__
=pod

=head1 NAME

Catalyst::Model::MongoDB - MongoDB model class for Catalyst

=head1 VERSION

version 0.07

=head1 SYNOPSIS

    #
    # Config
    #
    <Model::MyModel>
        host localhost
        port 27017
        dbname mydatabase
        collectionname preferedcollection
        gridfs preferedgridfs
    </Model::MyModel>

    #
    # Usage
    #
    $c->model('MyModel')->db                           # returns MongoDB::Connection->mydatabase
    $c->model('MyModel')->db('otherdb')                # returns ->otherdb
    $c->model('MyModel')->collection                   # returns ->mydatabase->preferedcollection
    $c->model('MyModel')->coll                         # the same...
    $c->model('MyModel')->c                            # the same...
    $c->model('MyModel')->c('otherdb.othercollection') # returns ->otherdb->othercollection
    $c->model('MyModel')->c('somecollection')          # returns ->mydatabase->somecollection
    $c->model('MyModel')->gridfs                       # returns ->mydatabase->get_gridfs('preferedgridfs')
    $c->model('MyModel')->g                            # the same...
    $c->model('MyModel')->g('somegridfs')              # returns ->mydatabase->get_gridfs('somegridfs')
    $c->model('MyModel')->g('otherdb.othergridfs')     # returns ->otherdb->get_gridfs('othergridfs')

    $c->model('MyModel')->run(...)                     # returns ->mydatabase->run_command(...)
    $c->model('MyModel')->eval(...)                    # returns ->mydatabase->eval(...)

    $c->model('MyModel')->database_names               # returns ->database_names
    $c->model('MyModel')->dbnames                      # the same...

=head1 DESCRIPTION

This model class exposes L<MongoDB::Connection> as a Catalyst model.

=head1 CONFIGURATION

You can pass the same configuration fields as when you make a new L<MongoDB::Connection>.

In addition you can also give a database name via dbname, a collection name via collectioname or 
a gridfs name via gridfsname.

=head1 METHODS

=head2 dbnames

=head2 database_names

List of databases.

=head2 collnames

=head2 collection_names

List of collection names of the default database. You cant give other database names here, if you need this please do:

  $c->model('MyModel')->db('otherdatabase')->collection_names

=head2 collection

=head2 coll

=head2 c

Gives back a MongoDB::Collection, you can also directly access other dbs collections, with "otherdb.othercollection".
If no collectionname is given he uses the default collectionname given on config.

=head2 gridfs

=head2 g

Gives back a MongoDB::GridFS. If no gridfsname is given, he uses the default gridfsname given on config.

=head2 run

Run a command via MongoDB::Database->run_command on the default database. You cant give other database names here,
if you need this please do:

  $c->model('MyModel')->db('otherdatabase')->run_command(...)

=head2 eval

Eval code via MongoDB::Database->eval on the default database. You cant give other database names here,
if you need this please do:

  $c->model('MyModel')->db('otherdatabase')->eval(...)

=head2 oid

Creates MongoDB::OID object

=head1 SUPPORT

IRC

  Join #catalyst on irc.perl.org and ask for Getty.

Repository

  http://github.com/Getty/p5-catalyst-model-mongodb
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/Getty/p5-catalyst-model-mongodb/issues

=head1 AUTHOR

Torsten Raudssus <torsten@raudssus.de> L<http://www.raudssus.de/>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Raudssus Social Software.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

