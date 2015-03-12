#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use LWP::UserAgent;
use IO::Interface;
use IO::Interface::Simple;
use File::Slurp;

my $nodes_config_url = "http://slaver-system.googlecode.com/hg/etc/nodes.conf";

my $json = JSON->new->allow_nonref;

my $interfaces;

foreach my $if ( IO::Interface::Simple->interfaces ) {
    $interfaces->{$if} = { address => $if->address, interface => $if };
}

my $ua = LWP::UserAgent->new;
$ua->timeout(60);
$ua->env_proxy;

my $ext_if = ""; # "lo0"
my $ext_addr = ""; # "127.0.0.1"
my $ext_nodes = [ ];

my $response = $ua->get($nodes_config_url);

if ($response->is_success) {
    my $nodes_config = $json->decode($response->decoded_content);
    my $nodes = $nodes_config->{nodes};
    foreach my $node ( @{ $nodes } ) {
	foreach my $if ( keys %{ $interfaces } ) {
	    if ( $interfaces->{$if}->{address} eq $node->{address} ) {
		$ext_if = $if;
		$ext_addr = $node->{address};
	    }
	}
	push ( @{ $ext_nodes }, $node->{address} ) if $ext_addr ne $node->{address};
    }
}

my $ext_nodes_list = join ' ', map { qq/"$_"/ } @{ $ext_nodes };

my $template = read_file ("iptables_rules.sh.tmpl");

$template =~ s/\{ext_if\}/$ext_if/isg;
$template =~ s/\{ext_addr\}/$ext_addr/isg;
$template =~ s/\{ext_nodes\}/$ext_nodes_list/isg;

write_file ("iptables_rules.sh", $template) if $ext_if && $ext_addr;
chmod 0755, "iptables_rules.sh";
