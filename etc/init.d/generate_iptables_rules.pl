#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use LWP::UserAgent;
use IO::Interface;
use IO::Interface::Simple;
use File::Slurp;

my $nodes_config_url = "https://raw.githubusercontent.com/ashevchuk/slaver-system/master/etc/nodes.conf";

my $json = JSON->new->allow_nonref;

my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
$ua->timeout(60);
$ua->env_proxy;

my $interfaces;

my $ext_if = ""; # "lo0"
my $ext_addr = ""; # "127.0.0.1"
my $ext_nodes = [ ];

my $response = $ua->get($nodes_config_url);

if ($response->is_success) {

    my $nodes_config = $json->decode($response->decoded_content);
    my $nodes = $nodes_config->{nodes};

    if ( $ARGV[0] && $ARGV[1] ) {
	foreach my $node ( @{ $nodes } ) {
	    if ( $node->{hostname} eq $ARGV[1] ) {
		$interfaces->{$ARGV[0]} = { address => $node->{address}, interface => $ARGV[0] };
		last;
	    }
	}
    }
    else {
	foreach my $if ( IO::Interface::Simple->interfaces ) {
	    $interfaces->{$if} = { address => $if->address, interface => $if };
	}
    }

    foreach my $node ( @{ $nodes } ) {
	foreach my $if ( keys %{ $interfaces } ) {
	    if ( $interfaces->{$if}->{address} eq $node->{address} ) {
		$ext_if = $if;
		$ext_addr = $node->{address};
	    }
	}
	push ( @{ $ext_nodes }, $node->{address} ) if $ext_addr ne $node->{address};
    }
} else {
    printf("Error while getting configuration: %s\n", $response->status_line);
    exit;
}

my $ext_nodes_list = join ' ', map { qq/"$_"/ } @{ $ext_nodes };

my $template = read_file ("/home/developer/devel/perl/Slaver/etc/init.d/iptables_rules.sh.tmpl");

$template =~ s/\{ext_if\}/$ext_if/isg;
$template =~ s/\{ext_addr\}/$ext_addr/isg;
$template =~ s/\{ext_nodes\}/$ext_nodes_list/isg;

write_file ($ARGV[2] || "iptables_rules.sh", $template) if $ext_if && $ext_addr;
chmod 0755, $ARGV[2] || "iptables_rules.sh";
