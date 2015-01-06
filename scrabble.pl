use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Gtk2 '-init';

use GUI::Window;

my $window = GUI::Window->new();

Gtk2->main();

