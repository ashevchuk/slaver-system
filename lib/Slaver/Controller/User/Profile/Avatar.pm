package Slaver::Controller::User::Profile::Avatar;
use Moose;
use namespace::autoclean;

use Data::Dumper;

use URI::Encode qw(uri_encode uri_decode);
use File::Basename;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

#__PACKAGE__->config(namespace => '');

sub upload : Local {
    my ($self, $c) = @_;

    my $upload = $c->request->uploads->{file};

    my $db = $c->model('Data::Provider::Adaptor')->db('avatars');

    my $grid = $db->get_gridfs;

    my $image_utils = $c->model('Content::Image::Utils');

    my $tmp_out_image_base_file_name = fileparse($upload->filename, qr/\.[^.]*/);
    my $tmp_out_image_full_file_name = $tmp_out_image_base_file_name . $c->config->{application}->{content}->{images}->{default}->{extension};

    my $tmp_out_image_file_name = $upload->tempname . $c->config->{application}->{content}->{images}->{default}->{extension};

    $image_utils->thumb_proportional({
	file => {
	    in => $upload->tempname,
	    out => $tmp_out_image_file_name
	}
    });

    my $upload_fh = IO::File->new($tmp_out_image_file_name, "r");
    $upload_fh->binmode();

    my $file_id = $grid->insert($upload_fh, {"filename" => $tmp_out_image_full_file_name});
    $upload_fh->close();
    unlink($tmp_out_image_file_name);

    my $user_db = $c->model('Data::Provider::Adaptor')->db('auth');
    my $user_coll = $user_db->get_collection('users');
    my $user = $user_coll->find_one({_id => $c->user->_id});

    $user->update({avatar => $file_id->value});

    push(@{$c->stash->{files}}, {
	name => $tmp_out_image_full_file_name,
	size => $upload->size,
	url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	thumbnail_url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	delete_url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	delete_type => "DELETE"
    });

    $c->forward('View::JSON');

#    $c->response->redirect($c->request->headers->referer);
}

sub get : Local {
    my ($self, $c) = @_;

    my $db = $c->model('Data::Provider::Adaptor')->db('auth');
    my $coll = $db->get_collection('users');

    my $user = $coll->find_one({_id => $c->user->_id});

    my $file_id = $user->avatar;

    $c->response->content_type('image/png');
    $c->res->header('Accept-Ranges' => 'none');
    $c->res->header('X-Accel-Redirect' => "/data/avatars/" . $file_id . "/avatar.png");
#    $c->response->redirect("/data/avatars/" . $file_id . "/avatar.png");
    $c->response->body($file_id);
}

sub slurp : Local {
    my ($self, $c) = @_;

    my $file_path = $c->request->params->{file_path};
    my $file_name = $c->request->params->{file_name};
    my $file_size = $c->request->params->{file_size};
    my $file_md5 = $c->request->params->{file_md5};
    my $file_content_type = $c->request->params->{file_content_type};

#    $file_name =~ s/%(..)/pack("c", hex($1))/ge;

    $file_name = uri_decode($file_name);
    utf8::decode($file_name);

    if ( defined $file_path && -e $file_path ) {

    my $db = $c->model('Data::Provider::Adaptor')->db('avatars');

    my $grid = $db->get_gridfs;

    my $image_utils = $c->model('Content::Image::Utils');

    my $tmp_out_image_base_file_name = fileparse($file_name, qr/\.[^.]*/);
    my $tmp_out_image_full_file_name = $tmp_out_image_base_file_name . $c->config->{application}->{content}->{images}->{default}->{extension};
    my $tmp_out_image_file_name = $file_path . $c->config->{application}->{content}->{images}->{default}->{extension};

    $image_utils->thumb_proportional({
	file => {
	    in => $file_path,
	    out => $tmp_out_image_file_name
	}
    });

    my $upload_fh = IO::File->new($tmp_out_image_file_name, "r");
    $upload_fh->binmode();

    my $file_id = $grid->insert($upload_fh, {"filename" => $tmp_out_image_full_file_name});
    $upload_fh->close();

    unlink($tmp_out_image_file_name);
    unlink($file_path);

    my $user_db = $c->model('Data::Provider::Adaptor')->db('auth');
    my $user_coll = $user_db->get_collection('users');
    my $user = $user_coll->find_one({_id => $c->user->_id});

    $user->update({avatar => $file_id->value});

    push(@{$c->stash->{files}}, {
	name => $tmp_out_image_full_file_name,
	size => $file_size,
	url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	thumbnail_url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	delete_url => $c->config->{application}->{url} . sprintf("/data/avatars/%s/%s", $file_id->value, $tmp_out_image_full_file_name),
	delete_type => "DELETE"
    });

    }
    else {
	$c->stash->{message} = q(No input);
	$c->response->headers->content_type('text/plain');
	$c->response->status(404);

	return $c->response->body("No input");
    }

    $c->forward('View::JSON');
}


__PACKAGE__->meta->make_immutable;

1;

