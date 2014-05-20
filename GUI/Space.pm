package GUI::Space;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Item);

use GUI::Utils;

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->set(
		x1 => $x, y1 => $y,
		x2 => $x + $side, y2 => $y + $side,
	);

	$self->show();
}

1;
