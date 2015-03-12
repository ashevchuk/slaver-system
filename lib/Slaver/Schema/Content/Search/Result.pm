package Slaver::Schema::Content::Search::Result;

use MongoDBx::Class::Moose;
use namespace::autoclean;
with 'MongoDBx::Class::Document';

use DateTime;

has 'session' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_session');
has 'score' => (is => 'ro', isa => 'Str', required => 0, writer => 'set_score');
has 'document_class' => (is => 'ro', isa => 'Str', required => 1, writer => 'set_document_class');
has 'issue' => (is => 'ro', isa => 'DateTime', traits => ['Parsed'], required => 1, default => sub { DateTime->now; }, writer => 'set_issue');

holds_one 'document' => (is => 'ro', isa => 'Slaver::Schema::Content::Search::Result::Document', required => 1, writer => 'set_document');

__PACKAGE__->meta->make_immutable;
