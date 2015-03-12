use strict;
use warnings;

use lib qw(lib);

use Slaver;

my $app = Slaver->apply_default_middlewares(Slaver->psgi_app(@_));
$app;
