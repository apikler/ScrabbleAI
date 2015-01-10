##########################################################################
# GUI::Tile
# Canvas element that represents a letter tile
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

package GUI::Tile;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use Gnome2::Canvas;

use GUI::Utils;

# $tile: The Backend::Tile that cooresponds to this GUI::Tile
sub new {
	my ($class, $root, $tile) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 1,
		fill_color_gdk => GUI::Utils::get_gdk_color(0xFF, 0xCC, 0x66),
	);

	$self->{tile} = $tile;

	$self->refresh_text();

	return $self;
}

# Returns the Backend::Tile that corresponds to this GUI::Tile
sub get_tile {
	my ($self) = @_;

	return $self->{tile};
}

# Returns 1 if the tile has been on the board since the beginning of of the turn,
# 0 otherwise.
sub is_committed {
	my ($self) = @_;

	return $self->{tile}->is_on_board();
}

# Refreshes the letter and value displayed for the user to match the Backend::Tile.
sub refresh_text {
	my ($self) = @_;

	my $letter = $self->{tile}->get() eq '*' ? '' : uc($self->{tile}->get());
	my $value = $letter eq '' ? '' : $self->{tile}->get_value();

	if ($self->{letter}) {
		$self->{letter}->destroy();
	}
	if ($self->{value}) {
		$self->{value}->destroy();
	}

	$self->{letter} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Text',
		text => $letter,
		family => 'Sans',
		anchor => 'center',
		weight => 500,
	);

	unless ($self->{tile}->is_blank()) {
		$self->{value} = Gnome2::Canvas::Item->new(
			$self,
			'Gnome2::Canvas::Text',
			text => $value,
			family => 'Sans',
			anchor => 'se',
		);
	}
}

# $side: Side length of this tile in pixels
sub draw {
	my ($self, $side) = @_;

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);

	# Arbitrary scaling factor for text, based on side length
	my $scale = $side / 27;

	if ($self->{letter}) {
		$self->{letter}->set(
			x => $side/2, y => $side/2,
			'size-points' => 15*$scale,
		);

		$self->{letter}->show();
	}

	if ($self->{value}) {
		$self->{value}->set(
			x => $side - 1, y => $side,
			'size-points' => 6*$scale,
		);

		$self->{letter}->show();
	}

	$self->{rect}->show();
	$self->show();
}

1;
