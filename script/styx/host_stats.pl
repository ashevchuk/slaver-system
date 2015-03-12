#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use DateTime;
use MongoDB;
use Digest::MD5 qw(md5_hex);
#use AnyEvent;
use Sys::Statistics::Linux;
use Linux::Proc::Net::TCP;

use Net::WebSocket::EV;
use HTTP::Server::EV;
use Digest::SHA1 qw(sha1_base64);

our $clients = { };

use Daemon::Generic;

my @proc_list = qw/nginx mongod mongos perl slaver fcgi/;

#my $exit_flag = AnyEvent->condvar;

our $json = JSON->new->utf8(1)->allow_nonref->allow_blessed;

our $lxs = Sys::Statistics::Linux->new(
        sysinfo   => 1,
        cpustats  => {
            init     => 1,
            initfile => '/tmp/cpustats.yml',
        },
        procstats => 1,
        memstats  => 1,
        pgswstats => 1,
        netstats  => 1,
        sockstats => 1,
        diskstats => 1,
        diskusage => 1,
        loadavg   => 1,
        filestats => 1,
        processes => 1
    );

$lxs->settime('%d/%m/%Y %H:%M:%S');

our $client;
our $database;
our $collection;

sub connect_db {
    $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
    $database   = $client->get_database( 'blackboard' );
    $collection = $database->get_collection( 'host.sys.stats' );
}

sub get_status {
    my %stat_hash;

    eval {
	%stat_hash = %{ $lxs->get };
    };

    $stat_hash{host} = $stat_hash{sysinfo}{hostname};
    $stat_hash{issue} = DateTime->now();
    my $disk_usage;

    foreach my $key ( keys %{ $stat_hash{diskusage} } ) {
	my $key_transformed = $key;
	$key_transformed =~ s{\.}{\_}sg;
	
	$disk_usage->{$key_transformed} = $stat_hash{diskusage}{$key};
    }

    $stat_hash{diskusage} = $disk_usage;

    my $sockets;
    my $sock_table = Linux::Proc::Net::TCP->read;

    foreach my $entry ( @{ $sock_table } ) {
	push @{ $sockets }, { local_addr => $entry->local_address, local_port => $entry->local_port, remote_addr => $entry->rem_address, remote_port => $entry->rem_port, status => sprintf ("%s", $entry->st ) };
    }

    $stat_hash{sockets} = $sockets;

    return \%stat_hash;
}

sub update_status {
    my $stat_hash = shift;

    my $id = $collection->update( { host => $stat_hash->{sysinfo}->{hostname} }, { "\$set" => $stat_hash }, { "upsert" => 1 } );

    return $id;
}

sub start_ws_service {

HTTP::Server::EV->new({cleanup_on_destroy => 1})->listen(5000, sub {
    my $cgi = $_[0];

    $cgi->header({
            STATUS          => '101 Switching Protocols',
            Upgrade         => "websocket",
            Connection      => "Upgrade",
            "Sec-WebSocket-Accept"  => scalar sha1_base64( $cgi->{headers}{"Sec-WebSocket-Key"} . "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" ).'=',
    });

    $cgi->{self} = $cgi; # circular. Keep object
    printf("received connect\n");
    $clients->{"$cgi"} = $cgi;
    $cgi->{buffer}->flush_wait(sub {

    $cgi->{websocket} = Net::WebSocket::EV::Server->new({
        fh => $cgi->{buffer}->give_up_handle,

        on_msg_recv => sub { 
            my ($rsv,$opcode,$msg, $status_code) = @_;
	    printf("received msg: %s\n", $msg);
#            $cgi->{websocket}->queue_msg($msg);
        },

        on_close => sub {
            my($code) = @_;
	    printf("connection close: %s\n", $code);
            #remove circular
	    delete $clients->{"$cgi"};
            $cgi->{self} = undef;
            $cgi = undef;
        },
        buffering => 1,
    });

    });
},  { threading => 0 });

    return;
}

newdaemon(
    progname => "host_stats",
    configfile => "/home/developer/devel/perl/Slaver/etc/host_stats.conf",
    pidbase => "/home/developer/devel/perl/Slaver/var/run",
    pidfile => "/home/developer/devel/perl/Slaver/var/run/host_stats.pid",
    foreground => 0,
    debug => 0,
    version => 1
);

sub gd_run {
#    my $exit_handler = AnyEvent->signal (signal => "TERM", cb => sub { $exit_flag->send(); });
#    my $stat_handler = AnyEvent->timer (after => 10, interval => 60, cb => \&update_status );

    connect_db;

    my $w1;

    my $wq = EV::signal 'QUIT', sub {
      warn "sigquit received\n";
      die;
    };

    my $wt = EV::signal 'TERM', sub {
      warn "sigterm received\n";
      die;
    };

    my $w0 = EV::timer 0, 60, sub {
	eval {
	    my $status = get_status;
	    update_status($status);
	};
	$w1->set (0, 2) if scalar keys %{ $clients };
    };

    $w1 = EV::timer 0, 600, sub {
	$w1->set (600, 600) unless scalar keys %{ $clients };
	return unless scalar keys %{ $clients };

	my $status;
	eval {
	    $status = get_status;
	};

	if ( scalar keys %{ $status } ) {
	    #print $json->encode( $status->{cpustats} );
	    foreach my $client ( keys %{ $clients } ) {
		#printf ("client: %s\n", $client);
		eval {
		    $clients->{$client}->{websocket}->queue_msg( $json->encode({
			cpu => $status->{cpustats},
			mem => $status->{memstats},
			host => $status->{host},
			host_hash => md5_hex( $status->{host} )
		    }));
		};
	    }
	}
    };

    start_ws_service;

    EV::run;

#    $exit_flag->recv;

#    undef $exit_handler;
#    undef $stat_handler;
}
