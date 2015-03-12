package Slaver::Model::Content::Image::Utils;
use Moose;

BEGIN { extends 'Catalyst::Model' }

use FileHandle;
use Image::Magick;

#__PACKAGE__->config(namespace => '');

#sub ACCEPT_CONTEXT { shift }

sub convert {
	my $self = shift;
	my $params = shift;

	my $in_file = $params->{file}->{in};
	my $out_file = $params->{file}->{out};

	my $source = Image::Magick->new;
	$source->Read($in_file);

	$source->Contrast();
#	$source->Normalize();
	$source->Enhance();

	$source->Write($out_file);
    }

sub thumb_proportional {
	my $self = shift;
	my $params = shift;

	my $in_file = $params->{file}->{in};
	my $out_file = $params->{file}->{out};

	my $my_width = $params->{dimensions}->{width} || 180;
	my $my_height = $params->{dimensions}->{height} || 180;

	my $source = Image::Magick->new;
	$source->Read($in_file);

	my($width, $height) = $source->Get('base-columns','base-rows'); 

	unless ($width) { return 0; };
	unless ($height) { return 0; };

	my ($pos_x, $pos_y);

	my $new_width = $my_width;
	my $new_height = $my_height;
	my $pc;

	if ($width > $height)
	    {
		$new_width = $my_width;
		$pos_x = 0;
		$pc = $width / $my_height;
		$new_height = $height / $pc;
		$pos_y = ($my_height - $new_height) / 2;
	    }
		else
		    {
			$new_height = $my_height;
			$pos_y = 0;
			$pc = $height / $my_height;
			$new_width = $width / $pc;
			$pos_x = ($my_width - $new_width) / 2;

		    }

	my $thumb = Image::Magick->new;

	$thumb->Set(size=>$my_width."x".$my_height);
	$thumb->ReadImage('xc:white');
	$thumb->Transparent(color=>"white");
	$source->Resize(width=>$new_width, height=>$new_height);

	$thumb->Composite(image=>$source, compose=>"over", gravity=>"Center");

	$thumb->Contrast();
#	$thumb->Normalize();
	$thumb->Enhance();

	$thumb->Write($out_file);
    }

sub crop_proportional {
	my $self = shift;
	my $params = shift;

	my $in_file = $params->{file}->{in};
	my $out_file = $params->{file}->{out};

	my $my_width = $params->{dimensions}->{width} || 180;
	my $my_height = $params->{dimensions}->{height} || 180;

	my $source = Image::Magick->new;
	$source->Read($in_file);

	my($width, $height) = $source->Get('base-columns','base-rows'); 

	unless ($width) { return 0; };
	unless ($height) { return 0; };

	my ($pos_x, $pos_y);

	my $new_width = $my_width;
	my $new_height = $my_height;
	my $pc;

	if ($width > $height)
	    {
		$new_width = $my_width;
		$pos_x = 0;
		$pc = $width / $my_height;
		$new_height = $height / $pc;
		$pos_y = ($my_height - $new_height) / 2;
	    }
		else
		    {
			$new_height = $my_height;
			$pos_y = 0;
			$pc = $height / $my_height;
			$new_width = $width / $pc;
			$pos_x = ($my_width - $new_width) / 2;

		    }

	my $thumb = Image::Magick->new;

	$thumb->Set(size=>$my_width."x".$my_height);
	$thumb->ReadImage('xc:white');
	$thumb->Transparent(color=>"white");
#	$source->Resize(width=>$new_width, height=>$new_height);
#	$thumb->Composite(image=>$source, compose=>"over", gravity=>"Center");

	$thumb = $source->Transform(crop=>$my_height.'x'.$my_width.'+0+0', gravity=>'Center');

	$thumb->Contrast();
#	$thumb->Normalize();
	$thumb->Enhance();

	$thumb->Write($out_file);
    }

__PACKAGE__->meta->make_immutable;

1;
