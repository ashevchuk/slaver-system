package Slaver::Schema::Content::Type::File::Props;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::EmbeddedDocument';

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
#	default   => sub { { likes => 0, dislikes => 0 }},
	required  => 0,
	predicate => 'has_votes',
	writer    => 'set_votes',
	reader    => 'get_votes',
	clearer   => 'clear_votes'
);

has 'md5_sum'=> (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { "" },
	required => 0,
	writer   => 'set_md5_sum',
	reader   => 'get_md5_sum',
	clearer  => 'clear_md5_sum',
);

has 'shortcut'=> (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { "" },
	required => 0,
	writer   => 'set_shortcut',
	reader   => 'get_shortcut',
	clearer  => 'clear_shortcut',
);

has 'mime_type'=> (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { "application/octet-stream" },
	required => 1,
	writer   => 'set_mime_type',
	reader   => 'get_mime_type',
	clearer  => 'clear_mime_type',
);

has 'media_type'=> (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { "application" },
	required => 1,
	writer   => 'set_media_type',
	reader   => 'get_media_type',
	clearer  => 'clear_media_type',
);

has 'media_sub_type'=> (
	is       => 'ro',
	isa      => 'Str',
	default  => sub { "octet-stream" },
	required => 1,
	writer   => 'set_media_sub_type',
	reader   => 'get_media_sub_type',
	clearer  => 'clear_media_sub_type',
);

has 'owner' => (
	is       => 'ro',
	isa      => 'MongoDB::OID',
	required => 1,
	writer   => 'set_owner',
	reader   => 'get_owner',
	clearer  => 'clear_owner',
);

#holds_many 'locations' => (
#	is        => 'ro',
#	isa       => 'Slaver::Schema::Content::Type::File::Location',
#	default   => sub { [] },
#	required  => 1,
#	predicate => 'has_location',
#	writer    => 'set_location',
#	reader    => 'get_location',
#	clearer   => 'clear_location'
#);

holds_many 'comments' => (
	is        => 'ro',
	isa       => 'Slaver::Schema::Content::Type::Comment',
#	default   => sub { [ ] },
	required  => 0,
	predicate => 'has_comments',
	writer    => 'set_comments',
	reader    => 'get_comments',
	clearer   => 'clear_comments',
	handles   => {
		all_comments    => 'elements',
		add_comment     => 'push',
		map_comments    => 'map',
		filter_comments => 'grep',
		find_comment    => 'first',
		join_comment    => 'join',
		count_comment   => 'count',
		has_no_comments => 'is_empty',
		sorted_comments => 'sort'
	}
);

has 'locations' => (
	is        => 'ro',
	isa       => 'ArrayRef[HashRef]',
	traits    => ['Array'],
	default   => sub { [] },
	required  => 0,
	predicate => 'has_location',
	writer    => 'set_location',
	reader    => 'get_location',
	clearer   => 'clear_location',
	handles   => {
		all_locations    => 'elements',
		add_location     => 'push',
		map_locations    => 'map',
		filter_locations => 'grep',
		find_location    => 'first',
		join_location    => 'join',
		count_location   => 'count',
		has_no_locations => 'is_empty',
		sorted_locations => 'sort'
	}
);

has 'thumbnails' => (
	is        => 'ro',
	isa       => 'ArrayRef[HashRef]',
	traits    => ['Array'],
	default   => sub { [] },
	required  => 0,
	predicate => 'has_thumbnail',
	writer    => 'set_thumbnail',
	reader    => 'get_thumbnail',
	clearer   => 'clear_thumbnail',
	handles   => {
		all_thumbnails    => 'elements',
		add_thumbnail     => 'push',
		map_thumbnails    => 'map',
		filter_thumbnails => 'grep',
		find_thumbnail    => 'first',
		join_thumbnail    => 'join',
		count_thumbnail   => 'count',
		has_no_thumbnails => 'is_empty',
		sorted_thumbnails => 'sort'
	}
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
