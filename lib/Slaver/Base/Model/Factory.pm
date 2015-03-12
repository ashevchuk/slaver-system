package Slaver::Base::Model::Factory;

use strict;
use warnings;

use Moose;

BEGIN { extends 'Catalyst::Model::Factory' }

__PACKAGE__->config( class => 'Slaver', description => 'Every request instance' );

1;
