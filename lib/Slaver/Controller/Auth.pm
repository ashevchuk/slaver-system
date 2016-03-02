package Slaver::Controller::Auth;

use Data::Dumper qw(Dumper);
use Moose;
use namespace::autoclean;
use Slaver::Resource::String::Auth;

use MongoDB::OID;

BEGIN { extends 'Slaver::Base::Controller::Generic' }
#use parent qw/Catalyst::Controller::RateLimit Catalyst::Controller/;

#__PACKAGE__->config(namespace => '');

sub login : Local {
    my ($self, $c) = @_;

    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};

    delete $c->stash->{user} if exists $c->stash->{user};
    delete $c->session->{username} if exists $c->session->{username};
    delete $c->session->{userinfo} if exists $c->session->{userinfo};

    $c->change_session_id;

    if ($username && $password) {

	if( $c->authenticate({username => $username, password => $password}) ) {
	    $c->stash( user => $username );
	    $c->session->{username} = $username;

	    $c->flash->{status_msg} = $c->loc(Slaver::Resource::String::Auth::RS_LOGIN_SUCCESSFUL);
	    $c->stash(status_msg => $c->loc(Slaver::Resource::String::Auth::RS_LOGIN_SUCCESSFUL));

	    $c->log->info("User login: ", $username);
	} else {
	    $c->stash(error_msg => $c->loc(Slaver::Resource::String::Auth::RS_BAD_USERNAME_OR_PASSWORD));
	    $c->flash->{error_msg} = $c->loc(Slaver::Resource::String::Auth::RS_BAD_USERNAME_OR_PASSWORD);

	    $c->log->error("Error while user login: ", $username);
	}
    } else {
	$c->stash(error_msg => $c->loc(Slaver::Resource::String::Auth::RS_BAD_USERNAME_OR_PASSWORD));
	$c->flash->{error_msg} = $c->loc(Slaver::Resource::String::Auth::RS_BAD_USERNAME_OR_PASSWORD);
    }

    $c->response->redirect($c->request->headers->referer);
}

sub logout : Local {
    my ($self, $c) = @_;

    $c->logout;
    $c->delete_session('logout');

    $c->change_session_id;

    $c->stash(status_msg => $c->loc(Slaver::Resource::String::Auth::RS_LOGOUT_SUCCESSFUL));
    $c->flash->{status_msg} = $c->loc(Slaver::Resource::String::Auth::RS_LOGOUT_SUCCESSFUL);

    delete $c->stash->{user} if exists $c->stash->{user};
    delete $c->session->{username} if exists $c->session->{username};
    delete $c->session->{userinfo} if exists $c->session->{userinfo};

    $c->response->redirect($c->uri_for('/'));
}

__PACKAGE__->meta->make_immutable;

1;
