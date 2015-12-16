package Slaver::Controller::File::Upload::Broker;
use Moose;
use namespace::autoclean;

use utf8;

use File::Basename;
use File::Copy;
use File::Temp;
use DateTime;
use Sys::Hostname;
use URI::Encode qw(uri_encode uri_decode);

use MongoDB::OID;

use MIME::Types;

BEGIN { extends 'Catalyst::Controller' }

#__PACKAGE__->config(namespace => '');

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

    my $hostname = hostname;

    my $db = $c->model('Data::Provider::Adaptor')->db('data');

    my $grid = $db->get_gridfs;

#    my $upload_fh = IO::File->new( $file_path, q(r) );
    my $upload_fh = IO::File->new( "/dev/null", q(r) );
    $upload_fh->binmode( );

    my $file_id = $grid->insert( $upload_fh, { q(filename) => $file_name, q(host) => $c->request->uri->host } );
    $upload_fh->close( );

    my $mime_types = MIME::Types->new( db_file => $c->config->{application}->{mime}->{db} );
    my $mime_type = $mime_types->mimeTypeOf( $file_name );
    #$mime_type->mediaType    $mime_type->subType
    #$mime_type->type()

    my ( $filename, $dirs, $suffix ) = fileparse( $file_name, qr/\.[^.]*/ );

    $suffix = defined $suffix ? $suffix : "." . $mime_type->subType;

#    my $temp_file = File::Temp::tempnam( $c->config->{application}->{content}->{images}->{converts_dir}, "upload_" );
#    $temp_file .= $suffix;

#    File::Copy::move($file_path, $temp_file);

    my $db_content = $c->model('Data::Provider::Adaptor')->db('content');

    my $content_files_collection = $db_content->get_collection('content');

    my $file_record = {
	_class => "Content::Type::File",
	props => {
	    caption => $file_name,
	    description => "No description for " . $file_name,
	    length => $file_size,
	    md5_sum => $file_md5,
	    thumbnails => [
	    ],
	    roles => [
		"content"
	    ],

	    locations => [
		{
		    "id" => $file_id,
		    "ref" => "data.fs.files"
        	}
	    ],
	    related => [
	    ],
	    categories => [
		MongoDB::OID->new(value => "514c2e7c08e4a52d1f000009")
	    ],
	    tags => [
		"images"
	    ]
	}
    };

    $file_record->{props}->{mime_type} = $mime_type ? $mime_type->type : "unknown";
    $file_record->{props}->{media_type} = $mime_type ? $mime_type->mediaType : "unknown";
    $file_record->{props}->{media_sub_type} = $mime_type ? $mime_type->subType : "unknown";
    $file_record->{props}->{owner} = $c->user_exists() ? MongoDB::OID->new(value => $c->session->{__user}) : MongoDB::OID->new(value => 0);

    my $content_file_id = $content_files_collection->insert($file_record);

    my $queue = $c->model('Data::Queue::Provider')->get_queue('service.image.convert');

    my $convert_task = {
	file_name => $file_path,
	caption => $file_name,
	extension => $suffix,
	file_id => $file_id->to_string,
	convert_to => "png",
	content_file_id => $content_file_id->to_string,
	tmp => $c->config->{application}->{content}->{images}->{converts_dir},
	remove => 1,
	reinsert => 1,
	issue => DateTime->now(),
	host => $hostname
    };

    $convert_task->{mime} = $mime_type ? $mime_type->type : "unknown";
    $convert_task->{media_type} = $mime_type ? $mime_type->mediaType : "unknown";
    $convert_task->{media_sub_type} = $mime_type ? $mime_type->subType : "unknown";

    $queue->add_task($convert_task);

    push(@{$c->stash->{files}}, {
	name => $file_name,
	size => $file_size,
	url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
	thumbnail_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
	delete_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
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

sub put : Local {
    my ($self, $c) = @_;

    if ( my $upload = $c->request->uploads->{file} ) {

    my $hostname = hostname;

    my $db = $c->model('Data::Provider::Adaptor')->db('data');

    my $grid = $db->get_gridfs;

    my $upload_fh = IO::File->new( $upload->tempname, q(r) );
    $upload_fh->binmode( );

    my $file_id = $grid->insert( $upload_fh, { q(filename) => $upload->filename } );
    $upload_fh->close( );

    my $mime_types = MIME::Types->new( db_file => $c->config->{application}->{mime}->{db} );
    my $mime_type = $mime_types->mimeTypeOf( $upload->filename );
    #$mime_type->mediaType    $mime_type->subType
    #$mime_type->type()

    my ( $filename, $dirs, $suffix ) = fileparse( $upload->filename, qr/\.[^.]*/ );

    $suffix = defined $suffix ? $suffix : "." . $mime_type->subType;

    my $temp_file = File::Temp::tempnam( $c->config->{application}->{content}->{images}->{converts_dir}, "upload_" );
    $temp_file .= $suffix;

    File::Copy::move($upload->tempname, $temp_file);

    my $db_content = $c->model('Data::Provider::Adaptor')->db('content');

    my $content_files_collection = $db_content->get_collection('content');
    my $content_file_id = $content_files_collection->insert({
	_class => "Content::Type::File",
	props => {
	    caption => $upload->filename,
	    description => "No description for " . $upload->filename,
	    length => $upload->size,
	    mime_type => $mime_type->type,
	    media_type => $mime_type->mediaType,
	    media_sub_type => $mime_type->subType,
	    thumbnails => [
	    ],
	    roles => [
		"content"
	    ],
	    owner => $c->user_exists() ? MongoDB::OID->new(value => $c->session->{__user}) : MongoDB::OID->new(value => 0),
	    locations => [
		{
		    "id" => $file_id,
		    "ref" => "data.fs.files"
        	}
	    ],
	    related => [
	    ],
	    categories => [
		MongoDB::OID->new(value => 0)
	    ],
	    tags => [
		"images"
	    ]
	}
    });

    my $queue = $c->model('Data::Queue::Provider')->get_queue('service.image.convert');

    $queue->add_task({
	file_name => $temp_file,
	extension => $suffix,
	file_id => $file_id->to_string,
	convert_to => "png",
	content_file_id => $content_file_id->to_string,
	mime => $mime_type->type,
	media_type => $mime_type->mediaType,
	media_sub_type => $mime_type->subType,
	tmp => $c->config->{application}->{content}->{images}->{converts_dir},
	remove => 1,
	issue => DateTime->now(),
	host => $hostname
    });

    push(@{$c->stash->{files}}, {
	name => $upload->filename,
	size => $upload->size,
	url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $upload->filename),
	thumbnail_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $upload->filename),
	delete_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $upload->filename),
	delete_type => "DELETE"
    });

    }
    else {
	$c->stash->{message} = q(No input);
    }

    $c->forward('View::JSON');
}

sub slurp_file : Local {
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

    my $hostname = hostname;

    my $db = $c->model('Data::Provider::Adaptor')->db('data');

    my $grid = $db->get_gridfs;

    my $upload_fh = IO::File->new( $file_path, q(r) );
    $upload_fh->binmode( );

    my $file_id = $grid->insert( $upload_fh, { q(filename) => $file_name, q(host) => $c->request->uri->host } );
    $upload_fh->close( );

    my $mime_types = MIME::Types->new( db_file => $c->config->{application}->{mime}->{db} );
    my $mime_type = $mime_types->mimeTypeOf( $file_name );
    #$mime_type->mediaType    $mime_type->subType
    #$mime_type->type()

    my ( $filename, $dirs, $suffix ) = fileparse( $file_name, qr/\.[^.]*/ );

    $suffix = defined $suffix ? $suffix : "." . $mime_type->subType;

#    my $temp_file = File::Temp::tempnam( $c->config->{application}->{content}->{images}->{converts_dir}, "upload_" );
#    $temp_file .= $suffix;

#    File::Copy::move($file_path, $temp_file);

    my $db_content = $c->model('Data::Provider::Adaptor')->db('content');

    my $content_files_collection = $db_content->get_collection('content');

    my $file_record = {
	_class => "Content::Type::File",
	props => {
	    caption => $file_name,
	    description => "No description for " . $file_name,
	    length => $file_size,
	    md5_sum => $file_md5,
	    thumbnails => [
	    ],
	    roles => [
		"content"
	    ],

	    locations => [
		{
		    "id" => $file_id,
		    "ref" => "data.fs.files"
        	}
	    ],
	    related => [
	    ],
	    categories => [
		MongoDB::OID->new(value => "514c2e7c08e4a52d1f000009")
	    ],
	    tags => [
		"images"
	    ]
	}
    };

    $file_record->{props}->{mime_type} = $mime_type ? $mime_type->type : "unknown";
    $file_record->{props}->{media_type} = $mime_type ? $mime_type->mediaType : "unknown";
    $file_record->{props}->{media_sub_type} = $mime_type ? $mime_type->subType : "unknown";
    $file_record->{props}->{owner} = $c->user_exists() ? MongoDB::OID->new(value => $c->session->{__user}) : MongoDB::OID->new(value => 0);

    my $content_file_id = $content_files_collection->insert($file_record);

    my $queue = $c->model('Data::Queue::Provider')->get_queue('service.image.convert');

    my $convert_task = {
	file_name => $file_path,
	extension => $suffix,
	file_id => $file_id->to_string,
	convert_to => "png",
	content_file_id => $content_file_id->to_string,
	tmp => $c->config->{application}->{content}->{images}->{converts_dir},
	remove => 1,
	issue => DateTime->now(),
	host => $hostname
    };

    $convert_task->{mime} = $mime_type ? $mime_type->type : "unknown";
    $convert_task->{media_type} = $mime_type ? $mime_type->mediaType : "unknown";
    $convert_task->{media_sub_type} = $mime_type ? $mime_type->subType : "unknown";

    $queue->add_task($convert_task);

    push(@{$c->stash->{files}}, {
	name => $file_name,
	size => $file_size,
	url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
	thumbnail_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
	delete_url => $c->config->{application}->{url} . sprintf("/data/files/%s/%s", $file_id->value, $file_name),
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

sub get : Local {
    my ($self, $c) = @_;

    my $db = $c->model('Data::Provider::Adaptor')->db('auth');
    my $coll = $db->get_collection('users');

    my $user = $coll->find_one({_id => $c->user->_id});

    my $file_id = $user->avatar;

    $c->response->redirect("/data/files/" . $file_id . "/avatar.png");
}

__PACKAGE__->meta->make_immutable;

1;
