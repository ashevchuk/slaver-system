package Slaver::Schema::Content::I18N::Locale;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

has 'locale' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_locale');
has 'msgid' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_msgid');
has 'msgstr' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_msgstr');

__PACKAGE__->meta->make_immutable;
