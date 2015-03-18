#!/usr/bin/env perl

use strict;
use warnings;

use Expect;
use Net::OpenSSH;
use subs::parallel;
use File::Slurp;
use Getopt::Long;
use Pod::Usage;

my $ssh;

my $timeout = 1600;
my $default_port = 22;
my $shell = "/bin/bash -l -i";
my $sync;

my $user;
my $password;
my $root_password;

my $plan;
my $need_root;
my $verbose;

my @hosts;

GetOptions (
    "timeout=i"       => \$timeout,
    "default_port=i"  => \$default_port,
    "plan=s"          => \$plan,
    "user=s"          => \$user,
    "password=s"      => \$password,
    "root_password=s" => \$root_password,
    "shell=s"         => \$shell,
    "root"            => \$need_root,
    "verbose"         => \$verbose,
    "sync"            => \$sync,
    "host=s"          => \@hosts
) or pod2usage(2);

@hosts = split(/,/, join(',', @hosts));

pod2usage(1) unless (scalar @hosts && $plan && $user && $password);

my @procs;
my @scripts;

printf("Executing %s plan @ %s\n", $plan, join(", ", @hosts)) if $verbose;

opendir (DIR, "./plan/" . $plan) or die $!;

while (my $file = readdir(DIR)) {
    push( @scripts, $file ) unless ( $file =~ m/^\./ ) ;
}

closedir(DIR);

foreach my $host (@hosts) {

    my $pproc = parallelize {

	my ($hostname, $port);
	if ( $host =~ m/\:/ ) {
	    ($hostname, $port) = $host =~ m/^(.*?)\:(.*?)$/;
	}
	else {
	    $hostname = $host;
	    $port = $default_port;
	}

	printf("Connecting %s port %s...\n", $hostname, $port) if $verbose;
	$ssh->{$hostname}->{sock} = Net::OpenSSH->new($hostname, port => $port, async => 1, user => $user, password => $password, master_opts => [-o => "StrictHostKeyChecking=no"] )
		unless defined $ssh->{$hostname}->{sock};

	my ($pty, $err, $pid);
	if ( $need_root ) {
	    printf("Switching user to root @ %s...\n", $hostname) if $verbose;
#	    ($pty, $err, $pid) = $ssh->{$hostname}->{sock}->open2pty( { stderr_to_stdout => 1 }, 'sudo', -p => 'password:', 'bash', '-i' ) or die "pipe failed: " . $ssh->{$hostname}->{sock}->error;
	    ($pty, $err, $pid) = $ssh->{$hostname}->{sock}->open2pty( { stderr_to_stdout => 1 }, 'su -c "' . $shell . '"' ) or die "pipe failed: " . $ssh->{$hostname}->{sock}->error;
	} else {
	    printf("Executing user shell @ %s...\n", $hostname) if $verbose;
	    ($pty, $err, $pid) = $ssh->{$hostname}->{sock}->open2pty( { stderr_to_stdout => 1 }, $shell) or die "pipe failed: " . $ssh->{$hostname}->{sock}->error;
	}

	my $expect = Expect->init($pty);

	mkdir("./log/$plan") unless -e "./log/$plan";
	$expect->log_file("./log/$plan/$hostname.log", "w");

	if ( $need_root ) {
	    printf("Entering root password @ %s...", $hostname) if $verbose;
	    $expect->expect($timeout,
	            [ qr/Password:/ => sub { shift->send( $root_password . "\n" ); exp_continue; } ],
	            [ qr/failure/   => sub { die "failure" } ],
	            [ qr/.*#\s+/    => sub { } ],
	            '-re', qr'[#>:] $', #'
	    ) or die "Timeout!";
	    printf("Done.\n") if $verbose;
	}

	foreach my $batch (@scripts) {
		my $script_name = "./plan/" . $plan . "/" . $batch;
		printf("Reading commands from file: %s\n", $script_name) if $verbose;
		open (my $FILE, "<", $script_name) or die $batch . ':' . $!;

		while (my $command = <$FILE>) {
			chomp ($command); next unless length $command; next if $command =~ m/^\#/;
			$expect->clear_accum();

			$command =~ s/\{HOSTNAME\}/$hostname/sg;

			if ( $command =~ m/^\{EXEC\}/isg ) {
			    my ( $cmd ) = $command =~ m/^\{EXEC\}(.*?)$/is;
			    chomp $cmd;
			    printf("Executing local command: %s\n", $cmd) if $verbose;
			    system($cmd);
			    next;
			}
			elsif ( $command =~ m/^\{UPLOAD\}/isg ) {
			    my ( $local_file, $remote_file ) = $command =~ m/^\{UPLOAD\}(.*?)\=\>(.*?)$/is;
			    printf("Uploading: %s @ %s:%s\n", $local_file, $hostname, $remote_file) if $verbose;
			    $ssh->{$hostname}->{sock}->scp_put({ verbose => 0, recursive => 1, glob => 1, async => 0 }, $local_file, $remote_file);
			    printf("Uploading done: %s @ %s:%s\n", $local_file, $hostname, $remote_file) if $verbose;
			    next;
			}
			else {
			    printf("Executing command: %s @ %s\n", $command, $hostname) if $verbose;
			    $expect->send("$command");
			    $expect->send(" ; (echo \"]DNE[\" | rev)\n");
			    $ssh->{$hostname}->{commands}++;
			    $expect->expect($timeout, [ qr/\[END\]/ => sub { printf ("%s @ Commands executed: %s\n", $hostname, $ssh->{$hostname}->{commands}) if $verbose; } ] );
			}
		}

		close $FILE;
	}

	printf("Exiting %s...\n", $hostname) if $verbose;
	$expect->send("\cd");

	$expect->log_file(undef);

	close $pty;

	undef $expect;
	undef $pty;
	undef $ssh->{$hostname}->{sock};
    };

    push @procs, $pproc unless $sync;
    print( $pproc || "" ) if $sync;
}

print( $_ || "" ) for @procs;

__END__

=head1 NAME

deploy.pl - Batch deployment via ssh

=head1 SYNOPSIS

deploy.pl [options]

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

B<This program> used to batch commands executing via ssh

=cut
