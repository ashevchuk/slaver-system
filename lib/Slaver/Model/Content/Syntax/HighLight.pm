package Slaver::Model::Content::Syntax::HighLight;
use Moose;

BEGIN { extends 'Catalyst::Model' }

use Text::Highlight 'preload';

#__PACKAGE__->config(namespace => '');

#sub ACCEPT_CONTEXT { shift }

sub render {
    my ($self, $args) = @_;

    my $th = new Text::Highlight(
	#wrapper => $args->{wrapper} || "<pre class=\"code\">%s</pre>\n",
	wrapper => "%s",
	markup => '<span class="%s">%s</span>'
    );

    chomp($args->{code});

    $args->{code} =~ s{^([\t\n\r\s])*?}{}gs;
    $args->{code} =~ s{\h}{ \\\_\\ }gs;

    my $result = $th->highlight($args->{language}, $args->{code});

    $result =~ s{\s\\\_\\\s}{\&nbsp\;}gs;

    my @lines = split("\n", $result);

    $result = '';

    for (my $i = 0; $i < scalar @lines; $i++) {
	$result .= sprintf("<div class=\"row\"><div class=\"cell code-line-number\">%s<\/div><div class=\"cell code-line-string\">%s</div></div>",
	    $i + 1, $lines[$i]
	);
    }

#    while($result =~ s/\n(.*?)\n//is) { $lc++; };

    return sprintf($args->{wrapper} || "<div class=\"code\"><div class=\"table\">%s</div></div>\n", $result);
}

__PACKAGE__->meta->make_immutable;

1;
