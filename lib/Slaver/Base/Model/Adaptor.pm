package Slaver::Base::Model::Adaptor;

use strict;
use warnings;

use Moose;

BEGIN { extends 'Catalyst::Model::Adaptor' }

__PACKAGE__->config( class => 'Slaver', description => 'Single instance' );

1;
