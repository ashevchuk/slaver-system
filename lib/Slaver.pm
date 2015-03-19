package Slaver;

use Moose;
use namespace::autoclean;

use utf8;

use MRO::Compat;
use Class::C3::Adopt::NEXT;
use Log::Log4perl::Catalyst;

#use Data::Dumper;
#use Data::Page;

use Catalyst::Runtime 5.90;

use Catalyst qw/
	-Debug
	StackTrace
	ConfigLoader

	Static::Simple

	Authentication
	Authorization::ACL
	Authorization::Roles

	Session
	Session::State::Cookie
	Session::Store::MongoDB


	StatusMessage

	I18N

	Cache
	Cache::FastMmap
	Cache::Store::FastMmap

	Widget
	SmartURI
/;

#		Session::Store::Memcached::Fast
extends 'Catalyst';
#with 'CatalystX::LeakChecker';

our $VERSION = '0.01';

__PACKAGE__->config(
	name => 'Slaver',
	# Disable deprecated behavior needed by old applications
	disable_component_resolution_regex_fallback => 1,
	enable_catalyst_header => 1, # Send X-Catalyst header
	encoding => 'UTF-8',
	using_frontend_proxy => 1,
	psgi_middleware => [
	    'RealIP' => { header => 'X-Forwarded-For' },
	    'SetEnvFromHeader',
	    'XForwardedFor'
	]
);
#	    'ReverseProxy',
#	    'SizeLimit' => {
#		max_unshared_size_in_kb => '262144', # 4MB
#		# min_shared_size_in_kb => '8192', # 8MB
#		# max_process_size_in_kb => '16384', # 16MB
#		check_every_n_requests => 10
#	    },


#__PACKAGE__->setup_middleware('ReverseProxy');

__PACKAGE__->log(Log::Log4perl::Catalyst->new(__PACKAGE__->path_to('slaver.log.conf')->stringify));

$SIG{__WARN__} = sub { __PACKAGE__->log->warn(@_); };

__PACKAGE__->setup();

with 'Slaver::Resource::ACL';

sub prepare_path {
    my $c = shift;

    $c->maybe::next::method(@_);

    my $language = $c->config->{application}->{content}->{localization}->{default}->{language};
    $language = $c->session->{locale} if $c->session->{locale};
    $language = $c->stash->{language} if $c->stash->{language};
    $language = $c->request->params->{lang} if $c->request->params->{lang};

    my $captures = {
	page => { default => 1, value => undef }
    };

    my @new_path_chunks;

    my %valid_languages = map { $_ => 1 } @{ $c->languages };

    my @path_chunks = split m[/], $c->request->path, -1;

#    $c->log->debug('Path chunks:', join(", ", @path_chunks));

    while ( my $path_chunk = shift @path_chunks ) {
	if ( exists $captures->{$path_chunk} ) {
	    $captures->{$path_chunk}->{value} = shift @path_chunks;
	} else {
	    push @new_path_chunks, $path_chunk;
	}
    }

    foreach my $capture ( keys %{ $captures } ) {
	$c->stash->{$capture} = $captures->{$capture}->{value} || $captures->{$capture}->{default};
    }

#    $c->log->debug('Captures:', Data::Dumper->Dump([$captures]));

    if ( @new_path_chunks && $valid_languages{$new_path_chunks[0]} ) {
        $language = shift @new_path_chunks;
    }

    my $path = join('/', @new_path_chunks) || '/';
    $c->request->path($path);

#    $c->request->uri->path("$language/" . $c->request->path);
    $c->request->uri->path($c->request->path);

#    my $base = $c->request->base;
#    $base->path($base->path . "$language/");

    $c->languages( [ $language ] );
    $c->session->{locale} = $language;
    $c->stash->{language} = $language;

    return;
}

1;
