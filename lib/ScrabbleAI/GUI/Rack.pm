##########################################################################
# ScrabbleAI::GUI::Rack
# Canvas element that draws the user's rack of tiles.
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

package ScrabbleAI::GUI::Rack;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use Gnome2::Canvas;

use ScrabbleAI::GUI::Utils;
use ScrabbleAI::GUI::Space::RackSpace;

use Data::Dumper;

use constant NUM_SPACES => 9;

#	$rack: The ScrabbleAI::Backend::Rack
sub new {
	my ($class, $root, $rack, $coords) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => ScrabbleAI::GUI::Utils::rack_color(),
	);

	my @spaces;
	foreach my $i (0..(NUM_SPACES - 1)) {
		my $gui_space = ScrabbleAI::GUI::Space::RackSpace->new($self, $rack);
		push(@spaces, $gui_space);
	}

	$self->{spaces} = \@spaces;
	$self->{rack} = $rack;

	$self->refresh();

	return $self;
}

# Ensures all the tiles currently held by the player (according to ScrabbleAI::Backend::Rack) are
# drawn and visible.
sub refresh {
	my ($self) = @_;

	my $tiles = $self->{rack}->get_tiles();
	foreach my $tile (@$tiles) {
		unless ($self->_tile_drawn($tile)) {
			$self->get_first_empty_space()->create_tile($tile);
		}
	}
}

# Returns 1 if the given ScrabbleAI::Backend::Tile has already been drawn in any space on this rack.
sub _tile_drawn {
	my ($self, $tile) = @_;

	foreach my $space (@{$self->{spaces}}) {
		if ($space->has_tile()) {
			return 1 if $space->get_tile()->get_tile() == $tile;
		}
	}

	return 0;
}

# Returns the leftmost ScrabbleAI::GUI::RackSpace that doesn't currently have a tile in it.
# Returns undef if no ScrabbleAI::GUI::RackSpace is empty.
sub get_first_empty_space {
	my ($self) = @_;

	foreach my $space (@{$self->{spaces}}) {
		return $space unless $space->has_tile();
	}

	return undef;
}

# Calling this causes the ScrabbleAI::Backend::Rack to reflect the tiles that are currently in
# the ScrabbleAI::GUI::Rack. For example, if the user has moved tiles onto the board such that the rack
# only has 3 remaining ScrabbleAI::GUI::Tiles, calling this would cause the ScrabbleAI::Backend::Rack to also contain
# the 3 corresponding ScrabbleAI::Backend::Tiles.
sub commit {
	my ($self) = @_;

	my @tiles;
	foreach my $space (@{$self->{spaces}}) {
		if ($space->has_tile()) {
			push(@tiles, $space->get_tile()->get_tile());
		}
	}

	$self->{rack}->set_tiles(\@tiles);
}

# Draws the rack in the given location, centered below the board.
# x: x-coordinate of the left side of the board
# y: y-coordinate of what will be the top of the rack
# side: side length of one tile
# padding: padding in pixels around the side of the rack
sub draw {
	my ($self, $x, $y, $side, $padding) = @_;

	my $board_side = 15*$side;
	my $width = NUM_SPACES*$side + 2*$padding;
	my $height = $side + 2*$padding;

	my $x1 = $x + ($board_side - $width)/2;

	$self->set(x => $x1, y=>$y);
	$self->{rect}->set(x1 => 0, y1 => 0, x2 => $width, y2 => $height);

	# Re-position the 8 spaces within the rack
	foreach my $i (0..$#{$self->{spaces}}) {
		$self->{spaces}[$i]->draw($padding + $i*$side, $padding, $side);
	}

	$self->{rect}->show();
	$self->show();
}

1;

