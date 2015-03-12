package Slaver::View::JSON;

use strict;
use warnings;
use base 'Catalyst::View::JSON';

use JSON::XS ();

sub encode_json {
    my($self, $c, $data) = @_;
    my $encoder = JSON::XS->new->ascii->pretty->allow_nonref;
    $encoder->allow_blessed(1);
    $encoder->convert_blessed(1);
    $encoder->encode($data);
}


=head1 NAME

DivisaReporting::View::JSON - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

Serg V. Gulko

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
