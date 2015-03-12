package Slaver::Base::Controller::Generic;
$Slaver::Base::Controller::Generic::VERSION = '1.19';

use strict;
use warnings;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub error_info : Private {
    my ( $self, $c, $message ) = @_;

    $c->stash->{content} = $message if $message;
    $c->stash->{content} ||= $c->loc("What?");

    $c->log->warn($c->stash->{content});

    $c->stash( template => 'templates/root/content/pages/status/error_info/index.tt2');
}

sub access_denied : Private {
    my ( $self, $c ) = @_;

    $c->log->warn("Access denied");

    $c->response->status(401);
    $c->stash( template => 'templates/root/content/pages/status/access_denied/index.tt2');
}

#sub begin :Private { }

1;
