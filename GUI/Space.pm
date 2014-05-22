package GUI::Space;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use GUI::Utils;
use GUI::Tile;

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->set(x => $x, y => $y);

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);
	$self->{rect}->show();

	if ($self->{gui_tile}) {
		$self->{gui_tile}->draw($side);
	}

	$self->show();
}

# Sets the given tile in this space to the given GUI::Tile. Does nothing
# if this space already has a tile.
sub set_tile {
	my ($self, $gui_tile) = @_;

	unless ($self->{gui_tile}) {
		$self->{gui_tile} = $gui_tile;
	}
}

# Creates a new GUI::Tile to be drawn inside this space based on the given Tile.
# Does nothing if this space already has a tile.
sub create_tile {
	my ($self, $tile) = @_;

	unless ($self->{gui_tile}) {
		$self->{gui_tile} = GUI::Tile->new($self, $tile);
	}
}

1;
