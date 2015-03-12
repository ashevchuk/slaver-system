package Slaver::Controller::User::Debug;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub session :Local {
    my ( $self, $c ) = @_;

    $c->stash->{session} = $c->session;
    $c->stash->{session_id} = $c->sessionid;
    $c->stash->{user} = $c->user();
    $c->stash->{user_exists} = $c->user_exists();

    $c->forward('View::JSON');
}

__PACKAGE__->meta->make_immutable;

1;
