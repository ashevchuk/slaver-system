package Log::Log4perl::Appender::MongoDB;

our @ISA = qw(Log::Log4perl::Appender);

use strict;

use MongoDB qw(:all);
use JSON::XS;
use Data::Dumper;
use Carp;
use Sys::Hostname;

use Log::Log4perl::Level;

use constant DB => "logs";
use constant PORT => "27017";
use constant HOST => "127.0.0.1";
use constant COLLECTION => "log";
use constant MAXLOG => 128;
use constant TTL_INDEX => "expires";

our $MONGOp;

sub new {
  my($class, %options) = @_;
  my $self = {
    buffer => [],
    level => $DEBUG,
    mongo => undef,
    trigger => sub { return 0 },
    trigger_level => undef,
    %options
  };

  $self->{'buffer_size'} = $self->{'buffer_size'} || MAXLOG;
  $self->{'hostname'} = $self->{'hostname'} || hostname;

  bless $self, $class;
  return $self;
}

sub get_mongo {
  my $self = shift;

  if ($self->{'mongo'}) {
    return $self->{'mongo'};
  }

  unless ($MONGOp) {
    my $host = $self->{'host'} || HOST;
    my $port = $self->{'port'} || PORT;
    $MONGOp = MongoDB::MongoClient->new(host => "mongodb://" . $host . ':' . $port);
  }

  my $db = $self->{'database'} || DB;
  my $conn = $MONGOp->get_database($db);

  $self->{'mongo'} = $conn;

  return $self->{'mongo'};
}

sub log {
  my ($self, %params) = @_;
  my $msg = $params{'message'};

  push(@{$self->{'buffer'}}, { level => $params{'log4p_level'}, msg => $msg });

  $self->flush() if scalar @{ $self->{'buffer'} } > $self->{'buffer_size'};
}

sub flush {
  my $self = shift;

    my $records;

  foreach my $record ( @{ $self->{buffer} } ) {
    my $val = {
	host => $self->{hostname},
	level => $record->{level},
	text => $record->{msg},
	maxlife => DateTime->now
     };
    push @{ $records }, $val;
  }

  $self->put($records);
  $self->{'buffer'} = [ ];
}

sub DESTROY {
  my $self = shift;
  if (Log::Log4perl::initialized()){
    if (scalar @{$self->{'buffer'}} > 0) {
      $self->flush();
    }
  }
}

sub put {
  my $self = shift;
  my ($records) = @_;

  my $c = $self->get_collection();

  my $id = $c->batch_insert($records, {safe => 0});

#  $self->do_expire($id);
}

sub do_expire {
  my $self = shift;
  my ($id) = @_;

  # force constant to eval as string
  my $max = $self->{'maxlogs'} || MAXLOG;
  my $c = $self->get_collection();
  my $num = $self->count_logs($id);
  #carp "$num of Max: $max ";
  if ($num > $max) {
    my $ttl = $self->{'ttl'} || TTL_INDEX . "";
    my $key = {'$and' => [{'_id' => $id},{$ttl => {'$exists' => 0}}]};
    my $cursor = $c->query($key)->skip($max)->sort({'$natural' => 1});
    while (my $obj = $cursor->next) {
      my $oid = $obj->{'_id'}->to_string;
      $self->set_ttl($oid);
    }
  }
}

sub count_logs {
  my $self = shift;
  my ($id) = @_;
  my $c = $self->get_collection();
  # force constant to eval as string
  my $ttl = $self->{'ttl'} || TTL_INDEX . "";
  my $key = {'$and' => [{'_id' => $id},{$ttl => {'$exists' => 0}}]};
  my $count = $c->count($key);
  return $count;
}

sub get_collection {
  my $self = shift;
  my $m = $self->get_mongo();
  my $collection = $self->{'collection'} || COLLECTION;
  my $c = $m->get_collection($collection);
  return $c;
}

sub set_ttl {
  my $self = shift;
  my ($oid) = @_;
  my $c = $self->get_collection();
  my $ttl = $self->{'ttl'} || TTL_INDEX . "";
  my $id = MongoDB::OID->new(value => $oid);
	my $key = {
		"_id" => $id
	};
	my $val = {
	  '$set' => {$ttl => DateTime->now}
	};
	$c->update($key,$val);
}

1;
