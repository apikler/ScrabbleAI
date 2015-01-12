##########################################################################
# ScrabbleAI::Backend::Space
# Representation of a space on the board. Can contain up to one tile, and
# can have a bonus.
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

package ScrabbleAI::Backend::Space;

use strict;
use warnings;

# Creates a new space with the given coordinates and the bonus. The bonus must
# be one of '2W', '3W', '2L', '3L', or '' (empty string) for no bonus.
sub new {
	my ($class, $i, $j, $bonus) = @_;
	
	my $self = bless({
		bonus => $bonus,
		tile => undef,
		i => $i,
		j => $j,
	}, $class);
	
	return $self;
}

# Returns the coordinates of this Space
sub get_coords {
	my ($self) = @_;

	return ($self->{i}, $self->{j});
}

# Returns the Tile on this Space, or undef if there is no Tile.
sub get_tile {
	my ($self) = @_;
	
	return $self->{tile};
}

# Sets the Tile in this Space to the given Tile.
sub set_tile {
	my ($self, $tile) = @_;
	
	if ($tile) {
		$tile->set_on_board(1);
		$tile->set_location($self->{i}, $self->{j});
	}
	else {
		$tile->set_on_board(0);
		$tile->clear_location();
	}

	$self->{tile} = $tile;
}

# If this Space has a Tile, the Tile is removed.
sub remove_tile {
	my ($self) = @_;

	$self->set_tile(undef);
}

# Returns the bonus of this tile in the same form as what is passed to $class->new().
# Returns empty string if there is no bonus.
sub get_bonus {
	my ($self) = @_;
	
	return $self->{bonus};
}

sub print {
	my ($self) = @_;
	
	print $self->{tile} ? uc($self->{tile}->get()) : '.';
}

1;
