package Slaver::Controller::Root;

use Moose;
use namespace::autoclean;

use File::Slurp;
use Data::Page;

use Log::Log4perl::MDC;

BEGIN { extends 'Slaver::Base::Controller::Generic' }

use Data::Dump qw(dump);

__PACKAGE__->config(namespace => '');

sub begin : Private {
    my ( $self, $c ) = @_;

    Log::Log4perl::MDC->put("ip", $c->req->address());

#    $c->log->debug("Remote IP: " . $c->req->address());

    my $page = $c->stash->{page};
    $page = $c->request->params->{page} if $c->request->params->{page};

    $c->stash->{page} = 1 unless $page =~ /^[+]?\d+$/ && $page > 0;

    my $pager = Data::Page->new;
    $pager->total_entries(0);
    $pager->entries_per_page($c->config->{application}->{content}->{pager}->{elements});
    $pager->current_page($page);

    $c->stash->{pager} = $pager;
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash('template' => 'templates/root/index.tt2');
}

sub default :Path {
    my ( $self, $c ) = @_;

    $c->response->status(404);

    $c->stash( template => 'templates/root/content/pages/status/not_found/index.tt2');
}

#sub end : ActionClass('RenderView') {}

sub end : Private {
    my ( $self, $c ) = @_;

    if ( $c->error ) {

	$self->return_error( $c );

    } else {

	if ( my $category_id = $c->stash->{category_id} ) {
	    my $category = $c->model('Content::Menu')->id_to_alias($category_id);
	    my $category_obj = $c->model('Content::Menu')->from_id($category);
	    my $path_to_category = $c->model('Content::Menu')->path_to($category);
	    $c->stash('breadcrumbs', $path_to_category);
	    $c->stash('category', $category_obj);
	}

    }

    $c->response->content_type('text/html; charset=utf-8') unless ( $c->response->content_type );

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    $c->forward('Slaver::View::UI');
}

sub return_error : Private {
    my ( $self, $c ) = @_;

    if ( scalar @{ $c->error } ) {

	eval {
	    for my $error ( @{ $c->error } ) {
		$c->log->error($error);
	    }
	};

#	$c->log->error(dump($c));

	$c->stash->{errors} = $c->error if $c->debug;
	$c->stash->{content} = dump($c) if $c->debug;

	$c->response->status(500);

	$c->stash->{template} = 'templates/root/content/pages/status/internal_error/index.tt2';

	if ( exists $c->{_stacktrace} ) {
	    my $log_trace;
	    my $stack_trace;

	    foreach my $trace_item (@{$c->{_stacktrace}}) {

		if ( -e $trace_item->{file} && my @lines = read_file($trace_item->{file}) ) {
		    my $start_slice = $trace_item->{line} - $c->config->{stacktrace}->{lines};
		    $start_slice = 0 if $start_slice < 0;

		    my $line_number = $start_slice;

		    my @code_slice = @lines[$start_slice..$trace_item->{line} + $c->config->{stacktrace}->{lines}];

		    if ( $c->debug ) {
			my @formated_lines;

			foreach my $line (@code_slice) {
			    $line_number++;
			    chomp $line;

			    my $line_style = $line_number == $trace_item->{line} ? "error-line" : "normal-line";
			    push @formated_lines, sprintf("<div class=\"source-line %s\"><div class=\"line-number\">%s:</div><div class=\"trace-item-code-source-line\"><pre class=\"code\"><code>%s</code></pre></div></div>", $line_style, $line_number, $line);
			}

			push(@{$stack_trace}, {
			    file    => $trace_item->{file},
			    line    => $trace_item->{line},
			    pkg     => $trace_item->{pkg},
			    content => join("\n", @formated_lines),
			});
		    }

		    push(@{$log_trace}, {
			file    => $trace_item->{file},
			line    => $trace_item->{line},
			pkg     => $trace_item->{pkg},
			trace => @code_slice
		    });
		}
	    }

	    delete $c->{_stacktrace};

#	    $c->log->error(dump($log_trace));
	    $c->stash->{stacktrace} = $stack_trace if $c->debug;
	}

	$c->clear_errors;
    }
}

__PACKAGE__->meta->make_immutable;

1;
