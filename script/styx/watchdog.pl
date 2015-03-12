#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use EV;
use JSON;
use File::Slurp;
use Daemon::Generic;
use Proc::ProcessTable;

sub watch {
    my $json = JSON->new->allow_nonref;

    my $services = [ ];
    my $processes = { };
    my $respawn_processes = [ ];

    my $services_data = read_file("/home/developer/devel/perl/Slaver/etc/services.json");

    $services = $json->decode( sprintf("{ \"proc_table\" : [ %s ] }", $services_data) );

    my $proc_table = Proc::ProcessTable->new;

    foreach my $proc ( @{ $proc_table->table } ) {
	$processes->{ $proc->{pid} } = $proc->{cmndline};
    }

    foreach my $proc ( @{ $services->{proc_table} } ) {
	my $pidfile = $proc->{pid_file};
	if( -f $pidfile ) {
	    my $pid = read_file( $pidfile );
	    chomp($pid);
	    if( exists $processes->{$pid} ) {
		if ( $processes->{$pid} eq $proc->{cmd} ) {
		    printf("Process %s is running\n", $proc->{name});
		} else {
		    printf("PID found, but for another processs. %s\n", $proc->{name});
		    push @{ $respawn_processes }, $proc;
		}
	    } else {
		printf("No PID found for %s processs\n", $proc->{name});
		push @{ $respawn_processes }, $proc;
	    }
	} else {
	    printf("No PID file for process %s\n", $proc->{name});
	    push @{ $respawn_processes }, $proc;
	}
    }

    foreach my $proc ( @{ $respawn_processes } ) {
	printf("Respawning process %s...\n", $proc->{name});
	my $pidfile = $proc->{pid_file};
#	unlink( $pidfile );
	system( sprintf("su -l - %s --command \"%s\"", $proc->{user}, $proc->{restart} );

	if ($? == -1) {
	    print "Failed to restart service: $!\n";
	} elsif ($? & 127) {
	    printf "Restart of service died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with':'without';
	} else {
	    printf "Process service successfully restarted, exit status:  %d\n", $? >> 8;
	}
    }
}

newdaemon(
    progname => "watchdog",
    configfile => "/home/developer/devel/perl/Slaver/etc/services.json",
    pidbase => "/home/developer/devel/perl/Slaver/var/run",
    pidfile => "/home/developer/devel/perl/Slaver/var/run/watchdog.pid",
    foreground => 0,
    debug => 0,
    version => 1
);

sub gd_run {

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
	    watch;
	};
    };

    EV::run;
}
