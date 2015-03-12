package Slaver::Base::Model::PerRequest;

use strict;
use warnings;

use Moose;

BEGIN { extends 'Catalyst::Model::Factory::PerRequest' }

__PACKAGE__->config( class => 'Slaver', description => 'Per request instance' );

1;
