#!/usr/bin/env perl

use strict;
use warnings;

use Nginx::ParseLog;

use Getopt::Long;
use Pod::Usage;

use AnyEvent;
use AnyEvent::Handle;

use DateTime;
use DateTime::Format::Strptime;

use MongoDB;

use Data::Dumper;

my $log;
my $timeout;
my $verbose;
my $host;

GetOptions (
    "log=s"           => \$log,
    "timeout=i"       => \$timeout,
    "verbose"         => \$verbose,
    "host=s"          => \$host
) or pod2usage(2);

pod2usage(1) unless ($log);

my $cv = AnyEvent->condvar;

my $strp_nginx_datetime = DateTime::Format::Strptime->new(
#   27/Aug/2015:19:56:32 +0000
    pattern   => '%d/%b/%Y:%H:%M:%S %z',
    locale    => 'en_US',
    time_zone => 'UTC',
);

my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'log' );
my $collection = $database->get_collection('access');
				
open my $fh, "<", $log or die;

my $handle = AnyEvent::Handle->new(
    fh       => $fh,
    on_error => sub { die "read error: $!"; },
    on_eof   => sub { print "done!\n"; close $fh; $cv->send; },
    on_read  => sub {
        my( $hdl ) = @_;
        $hdl->push_read( line => sub {
    	    my( $h, $line ) = @_;
    	    #print "line=$line\n";
	    my $deparsed = Nginx::ParseLog::parse($line);
	    my $dt = $strp_nginx_datetime->parse_datetime($deparsed->{'time'});
	    $deparsed->{'time'} = $dt if defined $dt;
#'bytes_send' => '4651',
#'time' => '27/Aug/2015:19:56:32 +0000',
#'ip' => '10.100.100.6',
#'remote_user' => '-',
#'user_agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
#'request' => 'GET /content/55467ea980791b2d6e2c0063 HTTP/1.1',
#'status' => '200',
#'referer' => '-',
	    ($deparsed->{method}, $deparsed->{uri}, $deparsed->{protocol}) = 
		$deparsed->{request} =~ m/^(.*?)\s(.*?)\s(.*?)$/sg;
	    $collection->insert($deparsed);
#	    print Data::Dumper->Dump([$deparsed]);
        } );
    }
);										

$cv->recv;

#my $deparsed = Nginx::ParseLog::parse($log_string);

__END__

=head1 NAME

slurp_access_log.pl - Slurp Access Log to MongoDB

=head1 SYNOPSIS

slurp_access_log.pl [options]

 Options:
   --plan=          plan name
   --timeout=       commands timeout
   --default_port=  ssh port
   --user=          ssh user name
   --password=      ssh user password
   --root_password= root password if needed
   --host=          host[:port] or comma(,) separated list
   --shell=         execute remote shell
   --root           use root to execute commands
   --verbose        verbose output
   --sync           sync(sequential) connections

=head1 OPTIONS

=over 8

=item B<--plan>

Plan name to execute

=item B<--host>

Host to connect: hostname[:port] or comma(,) separated list.

=item B<--shell>

Execute remote shell. Default: /bin/bash -l -i

=item B<--root>

Use "su" to change remote user to root.

=back

=head1 DESCRIPTION

B<This program> used to slurp NGINX access logs to MongoDB

=cut
