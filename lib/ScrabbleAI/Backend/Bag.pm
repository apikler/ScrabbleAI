##########################################################################
# ScrabbleAI::Backend::Bag
# An internal representation of the bag of letters that players draw from.
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

package ScrabbleAI::Backend::Bag;

use strict;
use warnings;

use ScrabbleAI::Backend::Tile;

# The tiles that appear in the bag and the corresponding tile counts
my %amounts = (
	A => 9,
	B => 2,
	C => 2,
	D => 4,
	E => 12,
	F => 2,
	G => 3,
	H => 2,
	I => 9,
	J => 1,
	K => 1,
	L => 4,
	M => 2,
	N => 6,
	O => 8,
	P => 2,
	Q => 1,
	R => 6,
	S => 4,
	T => 6,
	U => 4,
	V => 2,
	W => 2,
	X => 1,
	Y => 2,
	Z => 1,
	'*' => 2, # blank tiles
);

sub new {
	my ($class) = @_;
	
	my $self = bless({
		tiles => [],
	}, $class);
	
	$self->reset();
	
	return $self;
}

# Resets the Bag to its starting state - i.e., refills the Bag with new tiles
sub reset {
	my ($self) = @_;
	
	$self->{tiles} = [];

	for my $type (keys %amounts) {
		for my $i (1..$amounts{$type}) {
			push(@{$self->{tiles}}, ScrabbleAI::Backend::Tile->new($type));
		}
	}
}

# Adds the given tile to the Bag.
sub add {
	my ($self, $tile) = @_;

	$tile->set_on_board(0);
	$tile->clear_location();

	push(@{$self->{tiles}}, $tile);
}

# Returns the number of tiles in the Bag.
sub count {
	my ($self) = @_;
	
	return scalar(@{$self->{tiles}});
}

# Remove and return a Tile from the Bag. Returns undef if the Bag is empty.
sub draw {
	my ($self) = @_;
	
	return undef unless $self->count();
	
	my $index = int(rand($self->count()));
	
	return scalar(splice(@{$self->{tiles}}, $index, 1));
}

1;
