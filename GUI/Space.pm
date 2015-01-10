##########################################################################
# GUI::Space
# Canvas element that represents a space either in the rack or on the
# board. Can contain up to one tile.
#
# Copyright (C) 2015 Andrew Pikler
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

package GUI::Space;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use GUI::Utils;
use GUI::Tile;

# x, y: Location of the space on the canvas in pixel coordinates
# $side: Space side length in pixels
sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->set(x => $x, y => $y);

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);
	$self->{rect}->show();

	if ($self->{gui_tile}) {
		# Make the tile smaller by 1 pixel on each side so it will fit completely into
		# the space.
		$self->{gui_tile}->draw($side - 1);
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

# If this space has a tile, that tile is removed.
sub remove_tile {
	my ($self) = @_;

	$self->{gui_tile} = undef;
}

# Returns 1 if this space contains a tile; 0 otherwise
sub has_tile {
	my ($self) = @_;

	return defined $self->{gui_tile};
}

# If this space contains a tile, returns that GUI::Tile; returns undef otherwise.
sub get_tile {
	my ($self) = @_;

	if ($self->has_tile()) {
		return $self->{gui_tile};
	}
	else {
		return undef;
	}
}

sub get_coords {
	return ();
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
