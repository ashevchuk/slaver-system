#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(/home/developer/devel/perl/Slaver/lib);

#use ZMQx::Class;
use JSON::XS;
use MongoDBx::Queue;
use MongoDBx::Class;
use MongoDB::OID;

use File::Temp;
use File::Basename;

#use Data::Dumper;

use IPC::System::Simple qw(system systemx capture capturex);
use Sys::Hostname;

use Daemon::Generic;

use AnyEvent;

my $hostname = hostname;

my $exit_flag = AnyEvent->condvar;

my $dbx = MongoDBx::Class->new(
  namespace   => 'Slaver::Schema',
  search_dirs => ['/home/developer/devel/perl/Slaver/lib/Slaver/Schema']
);

my $conn           = $dbx->connect(host => 'localhost', port => 27017);
my $db             = $conn->get_database('content');
my $data_grid      = $conn->get_database('data')->get_gridfs;
my $thumbnail_grid = $conn->get_database('thumbnails')->get_gridfs;

#$person->update({ name => 'Some Smart Guy' });

my $queue = MongoDBx::Queue->new(
  database_name   => "queue",
  collection_name => "service.image.convert",
  client_options  => {
    host => "mongodb://127.0.0.1:27017",

    #		username => "",
    #		password => "",
  }
);

#my $publisher = ZMQx::Class->socket( 'PUB', bind => 'tcp://*:10000' );

my $coder = JSON::XS->new->ascii->pretty->allow_nonref->allow_blessed;

sub pdf2image {
  my $task           = shift;
  my $page           = shift || 0;
  my $temp_file      = File::Temp::tempnam($task->{tmp}, "thumb_");
  my $orig_temp_file = $temp_file . "orig." . $task->{convert_to};
  $temp_file .= "." . $task->{convert_to};
  my $conv_cmd = sprintf(
    "/home/developer/devel/perl/Slaver/script/misc/converters/pdf2image %s %s %s",
    $task->{file_name}, $page, $orig_temp_file);
  eval { system($conv_cmd); };
  unlink($orig_temp_file) if $@;
  return if $@;
  my $is_empty_image =
    `~/bin/convert $orig_temp_file -format "%[fx:mean>0.99?1:0]" info:`;
  unlink($orig_temp_file) if $is_empty_image;
  return if $is_empty_image;
  return unless (-e $orig_temp_file);

  my $conv_cmd2 = sprintf(
    "/home/developer/devel/perl/Slaver/script/misc/converters/image2image thumb %s %s 640 480",
    $orig_temp_file, $temp_file);
  eval { system($conv_cmd2); };
  unlink($orig_temp_file) if $@;
  unlink($temp_file)      if $@;
  return                  if $@;
  return unless (-e $temp_file);
  unlink($orig_temp_file);
  my ($filename, $dirs, $suffix) = fileparse($temp_file, qr/\.[^.]*/);

  my $fh = IO::File->new($temp_file, "r");
  my $thumbnail_id = $thumbnail_grid->insert($fh,
    {filename => $filename . "." . $task->{convert_to}});
  $fh->close;

  unlink($temp_file);

  my $file =
    $db->get_collection('content')
    ->find_one({_id => MongoDB::OID->new(value => $task->{content_file_id})});

  my $thumbs = $file->{props}->{thumbnails};
  push(
    @{$thumbs},
    { "id"  => $thumbnail_id,
      "ref" => 'thumbnails.fs.files'
    }
  );

  $db->get_collection('content')
    ->update({_id => MongoDB::OID->new(value => $task->{content_file_id})},
    {"\$set" => {"props.thumbnails", $thumbs}});
  return 1;
}

sub chm2image {
  my $task           = shift;
  my $page           = shift || 0;
  my $temp_file      = File::Temp::tempnam($task->{tmp}, "thumb_");
  my $orig_temp_file = $temp_file . "orig." . $task->{convert_to};
  $temp_file .= "." . $task->{convert_to};
  printf("converting chm image %s to %s\n",
    $task->{file_name}, $orig_temp_file);
  my $conv_cmd = sprintf(
    "/home/developer/devel/perl/Slaver/script/misc/converters/chm2image %s %s %s",
    $task->{file_name}, $page, $orig_temp_file);
  eval { system($conv_cmd); };
  unlink($orig_temp_file) if $@;
  return if $@;
  my $is_empty_image =
    `~/bin/convert $orig_temp_file -format "%[fx:mean>0.99?1:0]" info:`;
  unlink($orig_temp_file) if $is_empty_image;
  return if $is_empty_image;
  return unless (-e $orig_temp_file);
  printf("converting chm page to thumb %s to %s\n",
    $orig_temp_file, $temp_file);
  my $conv_cmd2 = sprintf(
    "/home/developer/devel/perl/Slaver/script/misc/converters/image2image thumb %s %s 640 480",
    $orig_temp_file, $temp_file);
  eval { system($conv_cmd2); };
  unlink($orig_temp_file) if $@;
  unlink($temp_file)      if $@;
  return                  if $@;
  return unless (-e $temp_file);
  unlink($orig_temp_file);
  my ($filename, $dirs, $suffix) = fileparse($temp_file, qr/\.[^.]*/);

  my $fh = IO::File->new($temp_file, "r");
  my $thumbnail_id = $thumbnail_grid->insert($fh,
    {filename => $filename . "." . $task->{convert_to}});
  $fh->close;

  unlink($temp_file);

  my $file =
    $db->get_collection('content')
    ->find_one({_id => MongoDB::OID->new(value => $task->{content_file_id})});

  my $thumbs = $file->{props}->{thumbnails};
  push(
    @{$thumbs},
    { "id"  => $thumbnail_id,
      "ref" => 'thumbnails.fs.files'
    }
  );

  $db->get_collection('content')
    ->update({_id => MongoDB::OID->new(value => $task->{content_file_id})},
    {"\$set" => {"props.thumbnails", $thumbs}});
  return 1;
}

sub image2image {
  my $task = shift;
  my $temp_file = File::Temp::tempnam($task->{tmp}, "thumb_");
  $temp_file .= "." . $task->{convert_to};

  my $conv_cmd = sprintf(
    "/home/developer/devel/perl/Slaver/script/misc/converters/image2image thumb %s %s 640 480",
    $task->{file_name}, $temp_file);
  eval { system($conv_cmd); };
  unlink($temp_file) if $@;
  return if $@;
  return unless (-e $temp_file);
  my ($filename, $dirs, $suffix) = fileparse($temp_file, qr/\.[^.]*/);

  my $fh = IO::File->new($temp_file, "r");
  my $thumbnail_id = $thumbnail_grid->insert($fh,
    {filename => $filename . "." . $task->{convert_to}});
  $fh->close;

  unlink($temp_file);

  my $file =
    $db->get_collection('content')
    ->find_one({_id => MongoDB::OID->new(value => $task->{content_file_id})});

  my $thumbs = $file->{props}->{thumbnails};
  push(
    @{$thumbs},
    { "id"  => $thumbnail_id,
      "ref" => 'thumbnails.fs.files'
    }
  );

  $db->get_collection('content')
    ->update({_id => MongoDB::OID->new(value => $task->{content_file_id})},
    {"\$set" => {"props.thumbnails", $thumbs}});
  return 1;
}

sub receive_tasks {
  while (my $task = $queue->reserve_task({query => {host => $hostname}})) {

#    		my $json = $coder->encode ($task);
#    		printf("received task: %s\n", $json);

    unless ( -e $task->{file_name} ) {
	$queue->reschedule_task($task);
	next;
    }

    if ($task->{reinsert}) {
	my $file_oid = MongoDB::OID->new(value => $task->{file_id});
	eval {
	    $data_grid->delete($file_oid);
	    my $fh = IO::File->new($task->{file_name}, "r");
	    my $file_id = $data_grid->insert($fh, {
		_id => $file_oid,
		filename => $task->{caption},
		host => $task->{host}
	    });
	    $fh->close;
	};

	if ($@) {
	    if ($task->{remove}) {
		unlink $task->{file_name};
	    }

	    $queue->remove_task($task);
	    next;
	}
    }

    if ($task->{media_type} eq "image") {
      if ($task->{media_sub_type} eq "vnd.djvu") {
        my $i         = 0;
        my $max_frame = 3;
        while (($i <= $max_frame) && ($i < 32)) {
          if (pdf2image($task, $i)) {
          }
          else {
            $max_frame++;
          }
          $i++;
        }
      }
    }

    if ($task->{media_type} eq "application") {
      if ($task->{media_sub_type} eq "pdf") {
        my $i         = 0;
        my $max_frame = 3;
        while (($i <= $max_frame) && ($i < 32)) {
          if (pdf2image($task, $i)) {
          }
          else {
            $max_frame++;
          }
          $i++;
        }
      }
    }

    if ($task->{media_type} eq "chemical") {
      if ($task->{media_sub_type} eq "chemdraw") {
        my $i         = 0;
        my $max_frame = 3;
        while (($i <= $max_frame) && ($i < 32)) {
          if (chm2image($task, $i)) {
          }
          else {
            $max_frame++;
          }
          $i++;
        }
        unlink($task->{file_name} . ".pdf");
      }
    }

    if ($task->{media_type} eq "image") {
      if (grep /^$task->{media_sub_type}$/, qw(xpixmap bmp png gif tiff jpeg))
      {
        image2image($task);
      }
    }

    if ($task->{media_type} eq "application") {
      if ($task->{media_sub_type} eq "postscript") {
        image2image($task);
      }
    }

    if (defined $task->{remove} && $task->{remove}) {
      unlink $task->{file_name};
    }

    $queue->remove_task($task);
  }

  #	select( undef, undef, undef, 1);
}

newdaemon(
  progname   => "image_converter",
  configfile => "/home/developer/devel/perl/Slaver/etc/image_converter.conf",
  pidbase    => "/home/developer/devel/perl/Slaver/var/run",
  pidfile => "/home/developer/devel/perl/Slaver/var/run/image_converter.pid",
  foreground => 0,
  debug      => 0,
  version    => 1
);

sub gd_run {
  my $exit_handler =
    AnyEvent->signal(signal => "TERM", cb => sub { $exit_flag->send(); });
  my $stat_handler = AnyEvent->timer(interval => 60, cb => \&receive_tasks);

  $exit_flag->recv;

  undef $exit_handler;
  undef $stat_handler;
}
