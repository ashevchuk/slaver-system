#!/usr/bin/env perl

use MongoDBx::Class;
use lib 'lib';

my $dbx = MongoDBx::Class->new(namespace => 'MyApp::Model::DB', search_dirs => ['./lib']);
 
my $conn = $dbx->connect(host => 'localhost', port => 27017);
$conn->safe(1); # we could've also just passed "safe => 1" to $dbx->connect() above
my $db = $conn->get_database('test');

my $collection = $db->get_collection('person');

my $person = $collection->insert({ first_name => 'Test', last_name => 'Tester', _class => 'Person' });

print "Created person ".$person->first_name." (".$person->last_name.")\n";
$person->update({ first_name => 'Some Smart Guy' });

my $cursor = $collection->find({first_name => 'Test'});


print $cursor->count;
use Data::Dumper;

while(my $rperson = $cursor->next)
    {
	#print Dumper($rperson);#->first_name;
	print $rperson->{first_name};
    }

$person->delete;
