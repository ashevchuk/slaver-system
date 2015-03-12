#!/usr/bin/env perl

use CSS;

my $css = CSS->new();

$css->read_file( $ARGV[0] );
$css->set_adaptor( 'CSS::Adaptor::Pretty' );
print $css->output();
