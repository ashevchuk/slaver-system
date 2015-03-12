package Slaver::Controller::Locale;

use utf8;

use Moose;
use namespace::autoclean;

use IO::File;
use File::Path qw(remove_tree);

BEGIN { extends 'Slaver::Base::Controller::Generic' }

__PACKAGE__->config(namespace => '');

sub locale : Local {
    my ($self, $c) = @_;

    my $lang = $c->request->params->{lang};

    $c->languages( $lang ? [ $lang ] : undef );

    $c->session->{locale} = $lang;
    $c->stash( language => $lang );
    #$c->response->headers->push_header( 'Vary' => 'Accept-Language' );

    $c->response->redirect($c->request->headers->referer);
}

sub localize : Local {
    my ($self, $c) = @_;

    my $localization = $c->model('Content::I18N::Locale')->localize($c);

    my $localization_items = ();

    my $localization_path = $c->config->{home}
	. $c->config->{application}->{content}->{localization}->{path}
	. $c->config->{application}->{content}->{path_separator};

    my $localization_default_file_name = $c->config->{home}
	. $c->config->{application}->{content}->{localization}->{path}
	. $c->config->{application}->{content}->{path_separator}
	. $c->config->{application}->{content}->{localization}->{default}->{file}
	. $c->config->{application}->{content}->{localization}->{extension};

    my $localization_default_language_file_name = $c->config->{home}
	. $c->config->{application}->{content}->{localization}->{path}
	. $c->config->{application}->{content}->{path_separator}
	. $c->config->{application}->{content}->{localization}->{default}->{language}
	. $c->config->{application}->{content}->{localization}->{extension};


    while (my $locale_item = $localization->next) {
	foreach my $locale ( @{ $locale_item->{locales} } ) {
	    foreach my $language ( keys %{ $locale } ) {
		push @{ $localization_items->{$language} }, {
		    msgid => $locale_item->{text},
		    msgstr => $locale->{$language}
		};
	    }
	}
    }

    foreach my $locale_items (keys %{$localization_items})
	{
		my $localization_file_name = $localization_path . $locale_items . $c->config->{application}->{content}->{localization}->{extension};

		my $locale_fh = IO::File->new(">" . $localization_file_name );
		binmode($locale_fh, ":utf8") if defined $locale_fh;

		if (defined($locale_fh)) {
			foreach my $header (@{$c->config->{application}->{content}->{localization}->{header}}) {
				print $locale_fh $header . "\n";
			}
		}

		print $locale_fh  if defined $locale_fh;

		foreach my $locale_item (@{$localization_items->{$locale_items}})
			{
				if (defined ($locale_fh))
					{
						$locale_item->{msgid} =~ s/\"/\\\"/gs;
						$locale_item->{msgstr} =~ s/\"/\\\"/gs;


						print $locale_fh sprintf("msgid \"%s\"\nmsgstr \"%s\"\n\n",
						    $locale_item->{msgid},
						    $locale_item->{msgstr}
						);
					}
			}

		$locale_fh->close if defined $locale_fh;
	}

    unlink($localization_default_file_name);

    symlink($localization_default_language_file_name, $localization_default_file_name);

    remove_tree("/home/developer/devel/perl/Slaver/root/cache/templates/Default");

    use Data::Dumper;
    $c->response->body(Dumper($localization_items));
    #$c->response->redirect('/');
}

__PACKAGE__->meta->make_immutable;

1;
