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

sub rack_color {
	return get_gdk_color(0, 150, 0);
}

# Returns the color of a space on the board corresponding to the given bonus.
# Valid bonuses are:
# '3W' => Triple word score
# '2W' => Double word score
# '3L' => Triple letter score
# '2L' => Double letter score
#
# If the given bonus is not one of the above, the color of a regular space will be returned.
sub get_space_color {
	my ($bonus) = @_;

	$bonus = uc($bonus);

	my %colors = (
		'3W' => GUI::Utils::get_gdk_color(210, 70, 50),
		'2W' => GUI::Utils::get_gdk_color(220, 150, 150),
		'3L' => GUI::Utils::get_gdk_color(50, 160, 205),
		'2L' => GUI::Utils::get_gdk_color(150, 200, 215),
	);

	if (defined $colors{$bonus}) {
		return $colors{$bonus};
	}
	else {
		return GUI::Utils::get_gdk_color(195, 190, 175);
	}
}

1;
