use strict;
use warnings;

use Gtk2 '-init';

use Game;
use GUI::Window;

my $game = Game->new();
$game->start();

my $window = GUI::Window->new($game);

Gtk2->main();

