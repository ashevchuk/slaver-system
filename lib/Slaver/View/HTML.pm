package Slaver::View::HTML;

use strict;
use warnings;

use parent 'Catalyst::View::TT';

use Template::Config;
use Template::Constants;
use Template::Stash::XS;

$Template::Config::STASH = 'Template::Stash::XS';

__PACKAGE__->config({
#     expose_methods => [qw/uri_for_css/],
     STASH => Template::Stash::XS->new,
});

#sub uri_for_css {
#    my ($self, $c, $filename) = @_;

#    return $c->uri_for('/static/css/' . $filename);
#}

1;
