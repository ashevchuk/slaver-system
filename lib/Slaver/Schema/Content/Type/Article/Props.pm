package Slaver::Schema::Content::Type::Article::Props;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

has 'body' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	writer   => 'set_body',
	reader   => 'get_body',
	clearer  => 'clear_body'
);

has 'caption' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	writer   => 'set_caption',
	reader   => 'get_caption',
	clearer  => 'clear_caption'
);

has 'description' => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	writer   => 'set_description',
	reader   => 'get_description',
	clearer  => 'clear_description'
);

has 'shortcut' => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,
	writer   => 'set_shortcut',
	reader   => 'get_shortcut',
	clearer  => 'clear_shortcut'
);

has 'length' => (
	is       => 'ro',
	isa      => 'Int',
	default  => sub { 0 },
	required => 1,
	writer   => 'set_length',
	reader   => 'get_length',
	clearer  => 'clear_length',
);

#has 'votes' => (
holds_one 'votes' => (
	is        => 'ro',
	isa       => 'Slaver::Schema::Content::Type::Vote',
#	isa       => 'HashRef',
#	default   => sub { { likes => 0, dislikes => 0 } },
	required  => 0,
	predicate => 'has_votes',
	writer    => 'set_votes',
	reader    => 'get_votes',
	clearer   => 'clear_votes'
);

has 'owner' => (
	is       => 'ro',
	isa      => 'MongoDB::OID',
	required => 1,
	writer   => 'set_owner',
	reader   => 'get_owner',
	clearer  => 'clear_owner',
);

holds_many 'related' => (
	is        => 'ro',
	isa       => 'Slaver::Schema::Content::Type::Related',
	default   => sub { [] },
	required  => 0,
	predicate => 'has_related',
	writer    => 'set_related',
	reader    => 'get_related',
	clearer   => 'clear_related'
);

holds_many 'comments' => (
	is        => 'ro',
	isa       => 'Slaver::Schema::Content::Type::Comment',
#	default   => sub { [] },
	required  => 0,
	predicate => 'has_comments',
	writer    => 'set_comments',
	reader    => 'get_comments',
	clearer   => 'clear_comments'
);

#holds_many 'roles' => (is => 'ro', isa => 'Slaver::Schema::Content::Role', required => 1, predicate => 'has_role', writer => 'set_role', reader => 'get_role', clearer => 'clear_role');
has 'roles' => (
	is        => 'ro',
	isa       => 'ArrayRef',
	traits    => ['Array'],
	default   => sub { [] },
	required  => 0,
	predicate => 'has_role',
	writer    => 'set_role',
	reader    => 'get_role',
	clearer   => 'clear_role',
	handles   => {
		all_roles    => 'elements',
		add_role     => 'push',
		map_roles    => 'map',
		filter_roles => 'grep',
		find_role    => 'first',
		join_role    => 'join',
		count_role   => 'count',
		has_no_roles => 'is_empty',
		sorted_roles => 'sort'
	}
);

#holds_many 'categories' => (is => 'ro', isa => 'Slaver::Schema::Content::Type::Category', predicate => 'has_categories', writer => 'set_categories', reader => 'get_categories');
has 'categories' => (
	is        => 'ro',
	isa       => 'ArrayRef[MongoDB::OID]',
	traits    => ['Array'],
	default   => sub { [] },
	predicate => 'has_categories',
	writer    => 'set_categories',
	reader    => 'get_categories',
	clearer   => 'clear_categories',
	handles   => {
		all_categories    => 'elements',
		add_category      => 'push',
		map_categories    => 'map',
		filter_categories => 'grep',
		find_category     => 'first',
		get_category      => 'get',
		join_categories   => 'join',
		count_categories  => 'count',
		has_no_categories => 'is_empty',
		sorted_categories => 'sort'
	}
);

#holds_many 'tags' => (is => 'ro', isa => 'Slaver::Schema::Content::Type::Tag', predicate => 'has_tags', writer => 'set_tags', reader => 'get_tags');
has 'tags' => (
	is        => 'ro',
	isa       => 'ArrayRef',
	traits    => ['Array'],
	default   => sub { [] },
	predicate => 'has_tags',
	writer    => 'set_tags',
	reader    => 'get_tags',
	clearer   => 'clear_tags',
	handles   => {
		all_tags    => 'elements',
		add_tag     => 'push',
		map_tags    => 'map',
		filter_tags => 'grep',
		find_tag    => 'first',
		get_tag     => 'get',
		join_tags   => 'join',
		count_tags  => 'count',
		has_no_tags => 'is_empty',
		sorted_tags => 'sort'
	}
);

__PACKAGE__->meta->make_immutable;
