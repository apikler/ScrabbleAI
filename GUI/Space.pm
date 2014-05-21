package GUI::Space;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use GUI::Utils;

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->set(x => $x, y => $y);

	$self->show();
}

1;
