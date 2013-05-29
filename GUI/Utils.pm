package GUI::Utils;

use strict;
use warnings;

use Gtk2 '-init';

# takes r,g,b values and returns a Gtk2::Gdk::Color
sub get_gdk_color {
	my ($r, $g, $b) = @_;
	
	my $scalar = 257;
	($r, $g, $b) = map {$_*$scalar} ($r, $g, $b);
	return Gtk2::Gdk::Color->new($r, $g, $b);
}

1;
