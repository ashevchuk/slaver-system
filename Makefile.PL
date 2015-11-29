#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Slaver';
all_from 'lib/Slaver.pm';

requires 'Catalyst::Runtime' => '5.90019';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::MongoDB';
requires 'Catalyst::Helper::Model::MongoDB';
requires 'Catalyst::Plugin::Session::Store::MongoDB';
requires 'Catalyst::Authentication::Store::MongoDB';
requires 'Catalyst::Restarter';
requires 'Catalyst::Plugin::Widget';
requires 'Catalyst::Plugin::Cache::Store::FastMmap';
requires 'Catalyst::Plugin::Cache::FastMmap';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Authentication::Credential::OpenID';
requires 'Catalyst::Plugin::Authentication::Credential::OpenID';

requires 'Plack::Middleware::RealIP';
requires 'Plack::Middleware::SetEnvFromHeader';
requires 'Plack::Middleware::SizeLimit';
requires 'Plack::Middleware::XForwardedFor';

requires 'HTTP::HeaderParser::XS';

requires 'Net::Server::PreFork';
requires 'Catalyst::Runtime';
requires 'Catalyst::Engine::CGI';
requires 'Catalyst::Engine::HTTP::Prefork';
requires 'Catalyst::Plugin::Authorization::Roles';

requires 'Text::Highlight';
requires 'MooseX::NonMoose';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::PassphraseColumn';
requires 'JSON::XS';

requires 'MongoDBx::Class';
requires 'MongoDBx::Queue';
requires 'Image::Magick';

requires 'MooseX::DeepAccessors';
requires 'MooseX::Traits::Pluggable';
requires 'CatalystX::Component::Traits';

requires 'DBIx::Class';
requires 'DBIx::Class::Schema';
requires 'CatalystX::Component::Traits';
requires 'Catalyst::Model::DBIC::Schema';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::CSV';

requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Digest::SHA';
requires 'Linux::Inotify2';

requires 'YAML::XS';
requires 'YAML::Syck';

requires 'XML::Simple';

requires 'WWW::Sitemap::XML';

requires 'Any::Moose';

#requires 'ZMQ::LibZMQ3'; # export PERL_ZMQ_BACKEND='ZMQ::LibZMQ3'
#requires 'ZMQ::Constants';
#requires 'ZMQ::ZMQ';
requires 'ZMQx::Class';
#requires 'POEx::ZMQ3';

requires 'Data::Localize::Storage::MongoDB';

requires 'Log::Log4perl';
requires 'Log::Log4perl::Catalyst';

requires 'Template::Plugin::Class';
requires 'Template::Plugin::AddTime';
requires 'Template::Plugin::Body';
requires 'Template::Plugin::Number::Format';
requires 'Template::Plugin::Perl';
requires 'Template::Plugin::RoundRobin';
requires 'Template::Plugin::Shuffle';
requires 'Template::Plugin::Subst';
requires 'Template::Plugin::String::Truncate';
requires 'Template::Plugin::Text::Filter::URI';
requires 'Template::Plugin::Time::Duration';
requires 'Template::Plugin::TimeDate';
requires 'Template::Plugin::Timer';
requires 'Template::Plugin::TruncateByWord';
requires 'Template::Plugin::VMethods';
requires 'Template::Plugin::Comma';
requires 'Template::Plugin::DataPrinter';
requires 'Template::Plugin::DateTime';
requires 'Template::Plugin::DateTime::Format';
requires 'Template::Plugin::Filter::Minify::CSS';
requires 'Template::Plugin::Filter::Minify::CSS::XS';
requires 'Template::Plugin::Filter::Minify::JavaScript';
requires 'Template::Plugin::Filter::Minify::JavaScript::XS';
requires 'Template::Plugin::Filter::MinifyHTML';
requires 'Template::Plugin::Filter::String::Truncate';
requires 'Template::Plugin::HighlightPerl';
requires 'Template::Plugin::HtmlToText';
requires 'Template::Plugin::JavaScript';
requires 'Template::Plugin::LanguageName';
requires 'Template::Plugin::ListOps';
requires 'Template::Plugin::ListUtil';
requires 'Template::Plugin::JSON';
requires 'Template::Plugin::Cache';
requires 'Template::Plugin::IO::All';
requires 'Template::Plugin::Digest::MD5';

requires 'App::cpanoutdated';

requires 'Linux::Proc::Net::TCP';
requires 'Daemon::Generic';

requires 'Expect';
requires 'Net::OpenSSH';

requires 'FCGI';
requires 'FCGI::ProcManager';

requires 'Term::Size::Any';

requires 'MIME::Types';
requires 'IPC::System::Simple';
requires 'IO::Interface';
requires 'Catalyst::Plugin::SmartURI';

requires 'Expect';
requires 'Net::OpenSSH';

requires 'Coro';
requires 'subs::parallel';
requires 'File::Slurp';
requires 'Getopt::Long';
requires 'Pod::Usage';
requires 'AnyEvent::Timer::Cron';
requires 'Proc::ProcessTable';
requires 'URI::Encode';

requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Plugin::Authorization::ACL';

requires 'Cache::Memcached::Fast';
requires 'URI::SmartURI';
requires 'CatalystX::LeakChecker';
requires 'CatalystX::Profile';

requires 'Log::Dispatch::FileRotate';
requires 'Catalyst::Plugin::Cache::Memcached::Fast';
requires 'Catalyst::Plugin::PageCache';

requires 'HTML::Escape';

requires 'WWW::Sitemap::XML';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
