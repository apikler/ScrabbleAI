##########################################################################
# ScrabbleAI::GUI::Space::BoardSpace
# Canvas element that inherits from ScrabbleAI::GUI::Space, and represents a space
# on the board
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

package ScrabbleAI::GUI::Space::BoardSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(ScrabbleAI::GUI::Space);

use Gnome2::Canvas;

use ScrabbleAI::GUI::Utils;

sub new {
	my ($class, $root, $space) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => ScrabbleAI::GUI::Utils::get_space_color($space->get_bonus()),
	);

	$self->{space} = $space;

	return $self;
}

sub set_tile {
	my ($self, $gui_tile) = @_;

	if (!$self->{gui_tile} && !$self->{space}->get_tile()) {
		$self->{gui_tile} = $gui_tile;
	}
}

# If this space has a tile, that tile is removed.
sub remove_tile {
	my ($self) = @_;

	$self->SUPER::remove_tile();
}

# If there's a tile on this space, it is placed onto the Board (the
# back-end Board, not the ScrabbleAI::GUI::Board)
sub commit {
	my ($self) = @_;

	if ($self->{gui_tile}) {
		$self->{space}->set_tile($self->{gui_tile}->get_tile());
	}
}

# Returns the (i, j) board coordinates of this space.
sub get_coords {
	my ($self) = @_;

	return $self->{space}->get_coords();
}

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->SUPER::draw($x, $y, $side);
}

1;
