package Slaver::Model::Data::Provider::Adaptor;
use strict;
use warnings;

use Moose;

#BEGIN { extends 'Catalyst::Model::Adaptor' }
BEGIN { extends 'Slaver::Base::Model::Adaptor' }

__PACKAGE__->config( class => 'Slaver::Model::Data::Provider' );

#__PACKAGE__->mk_accessors(qw|context|);

#sub ACCEPT_CONTEXT { my ($self, $context, @args) = @_; $self->context($context); return $self; }


1;
