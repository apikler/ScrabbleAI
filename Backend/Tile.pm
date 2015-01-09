##########################################################################
# Backend::Tile
# Representation of a tile, with a letter and a point value.
# Tiles can be in one of three places: in the Bag, in a player's Rack, or
# on the Board.
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

package Backend::Tile;

use strict;
use warnings;

# Point values of each letter
my %values = (
	A => 1,
	B => 3,
	C => 3,
	D => 2,
	E => 1,
	F => 4,
	G => 2,
	H => 4,
	I => 1,
	J => 8,
	K => 5,
	L => 1,
	M => 3,
	N => 1,
	O => 1,
	P => 3,
	Q => 10,
	R => 1,
	S => 1,
	T => 1,
	U => 1,
	V => 4,
	W => 4,
	X => 8,
	Y => 4,
	Z => 10,
	'*' => 0,
);

# Creates a new letter with the given type: a lower-case letter, or '*' for a blank tile.
sub new {
	my ($class, $type) = @_;
	
	my $self = bless({
		type => lc($type),
		value => $values{uc($type)},
		# The letter is the actual letter this tile represents on the board; for non-blank tiles
		# this is the same as the type. For blanks, this is * until set_blank_letter is called.
		letter => lc($type),
		on_board => 0, # Flag that indicates whether this tile has been placed on the board.
		location => '', # Coordinates of this tile
	}, $class);
	
	return $self;
}

# Returns the point value of this tile
sub get_value {
	my ($self) = @_;
	
	return $self->{value};
}

# Returns the letter of this tile in lower case.
# See NOTE below under $self->get_type().
sub get {
	my ($self) = @_;
	
	return $self->{letter};
}

# Returns the type of this Tile.
# NOTE: The "letter" and "type" of a Tile are always the same, except in the
# case of a blank tile. A blank will start out with '*' as both its letter and
# type, but once it is on the board the letter attribute will take on the value
# of the actual letter it represents.
sub get_type {
	my ($self) = @_;

	return $self->{type};
}

sub set_on_board {
	my ($self, $on_board) = @_;
	$self->{on_board} = $on_board;
}

sub is_on_board {
	my ($self) = @_;
	return $self->{on_board};
}

sub set_location {
	my ($self, $i, $j) = @_;
	$self->{location} = "$i,$j";
}

sub clear_location {
	my ($self) = @_;
	$self->{location} = '';
}

sub get_location {
	my ($self) = @_;
	return $self->{location};
}

# If this tile is a blank, sets the letter. Otherwise, does nothing.
sub set_blank_letter {
	my ($self, $letter) = @_;
	
	$self->{letter} = lc($letter) if $self->is_blank();
}

sub is_blank {
	my ($self) = @_;
	
	return $self->{type} eq '*';
}

# Returns an arrayref of allowed letters based on %values above.
# (This is the keys of %values, lower case, without the '*')
sub get_allowed_letters {
	my @letters = map {lc($_)} grep {$_ ne '*'} keys %values;
	return \@letters;
}

1;
