package Slaver::Controller::User;
use Moose;
use namespace::autoclean;

use Slaver::Resource::String::Auth;
use Slaver::Resource::String::User;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub registration : Local {
    my ($self, $c) = @_;

#    $c->stash('include_templates' => [ 'templates/root/content/pages/user/registration/index.tt2' ]);
#    $c->stash('template' => 'templates/root/index.tt2');
    $c->stash( template => 'templates/root/content/pages/user/registration/index.tt2');
}

sub repair : Local {
    my ($self, $c) = @_;

    $c->stash('template' => 'templates/root/content/pages/user/repair/index.tt2');
}

sub register : Local {
    my ($self, $c) = @_;

    my $name = $c->request->params->{'name'};
    my $username = $c->request->params->{'username'};
    my $password = $c->request->params->{'password'};
    my $retype_password = $c->request->params->{'repeat-password'};

    if ( $name && $username && $password && $retype_password ) {

	if ($password eq $retype_password) {
	    my $db = $c->model('Data::Provider::Adaptor')->db('auth');
	    my $coll = $db->get_collection('users');

	    my $user = $coll->find_one({ username => $username });

	    if (defined($user)) {
		    $c->flash->{error_msg} = $c->loc(Slaver::Resource::String::User::RS_USER_ALREADY_REGISTERED);
		    $c->stash(error_msg => $c->loc(Slaver::Resource::String::User::RS_USER_ALREADY_REGISTERED));

		    return $c->response->redirect($c->request->headers->referer);
	    }
	    else {
		my $avatar = $self->create_default_avatar($c);

		$user = $coll->insert({
		    name => $name,
		    username => $username,
		    password => $password,
		    avatar => $avatar,
		    roles => ['user'],
		    _class => "Auth::Users"
		});

		if (defined($user)) {
		    $c->flash->{status_msg} = $c->loc(Slaver::Resource::String::User::RS_USER_REGISTERED_SUCCESSFUL);
		    $c->stash(status_msg => $c->loc(Slaver::Resource::String::User::RS_USER_REGISTERED_SUCCESSFUL));
		    $c->session->{username} = $username;

		    if($c->authenticate({username => $username, password => $password})) {
			#$c->flash->{status_msg} = $c->loc(Slaver::Resource::String::Auth::RS_LOGIN_SUCCESSFUL);
			#$c->stash(status_msg => $c->loc(Slaver::Resource::String::Auth::RS_LOGIN_SUCCESSFUL));
		    }

		    return $c->response->redirect("/");
		}
		else {
		    $c->stash(error_msg => $c->loc(Slaver::Resource::String::User::RS_REGISTRATION_INTERNAL_ERROR));
		    $c->flash->{error_msg} = $c->loc(Slaver::Resource::String::User::RS_REGISTRATION_INTERNAL_ERROR);

		    return $c->response->redirect($c->request->headers->referer);
		}
	    }

	}
	else {
	    $c->stash(error_msg => $c->loc(Slaver::Resource::String::User::RS_PASSWORDS_IS_NOT_EQUAL));
	    $c->flash->{error_msg} = $c->loc(Slaver::Resource::String::User::RS_PASSWORDS_IS_NOT_EQUAL);
	    return $c->response->redirect($c->request->headers->referer);
	}

    }
    else {
	$c->stash(error_msg => $c->loc(Slaver::Resource::String::Auth::RS_USERNAME_OR_PASSWORD_IS_NOT_SPECIFIED));
	$c->flash->{error_msg} = $c->loc(Slaver::Resource::String::Auth::RS_USERNAME_OR_PASSWORD_IS_NOT_SPECIFIED);
	return $c->response->redirect($c->request->headers->referer);
    }

    $c->response->redirect($c->request->headers->referer);
}

sub create_default_avatar : Private {
    my ($self, $c) = @_;

    my $db = $c->model('Data::Provider::Adaptor')->db('avatars');
    my $image_utils = $c->model('Content::Image::Utils');

    my $grid = $db->get_gridfs;

    my $tmp_out_image_file_name = sprintf("avatar_img_%d", int(time * rand(time)));
    my $tmp_out_image_full_file_name = $c->config->{application}->{content}->{defaults}->{temp} . "/" . $tmp_out_image_file_name . $c->config->{application}->{content}->{images}->{default}->{extension};

    $image_utils->thumb_proportional({
	file => {
	    in => $c->config->{application}->{content}->{users}->{default}->{avatar},
	    out => $tmp_out_image_full_file_name
	}
    });

    my $upload_fh = IO::File->new($tmp_out_image_full_file_name, "r");
    $upload_fh->binmode();

    my $file_id = $grid->insert($upload_fh, {"filename" => $tmp_out_image_full_file_name});
    $upload_fh->close();

    unlink( $tmp_out_image_full_file_name );

    return $file_id->to_string;
}

__PACKAGE__->meta->make_immutable;

1;
