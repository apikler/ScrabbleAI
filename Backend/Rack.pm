##########################################################################
# Backend::Rack
# A representation of a player's rack. Can contain any number of tiles
# (although in practice this is limited by the game to seven).
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

package Backend::Rack;

use strict;
use warnings;

use Backend::Tile;

sub new {
	my ($class) = @_;
	
	my $self = bless({
		tiles => [],
	}, $class);
	
	return $self;
}

# Adds the given Tile to the Rack.
sub add_tile {
	my ($self, $tile) = @_;
	
	push(@{$self->{tiles}}, $tile);
}

# Returns an arrayref of the Tiles in this Rack.
sub get_tiles {
	my ($self) = @_;

	my @tiles = @{$self->{tiles}};
	return \@tiles;
}

# Adds all the tiles in the given arrayref to the Rack.
sub set_tiles {
	my ($self, $tiles) = @_;

	my @tiles_copy = @$tiles;
	$self->{tiles} = \@tiles_copy;
}

# Empties the Rack of tiles.
sub empty {
	my ($self) = @_;
	$self->set_tiles([]);
}

# Sets the contents of the rack to the tiles in $string.
sub set {
	my ($self, $string) = @_;
	
	$self->{tiles} = [];
	my @letters = split('', $string);
	for my $letter (@letters) {
		$self->add_tile(Tile->new($letter));
	}
}

# Returns 1 if this Rack contains at least one Tile that represents the given
# letter (character). '*' can be used to check for blank tiles.
sub contains {
	my ($self, $letter) = @_;
	
	$letter = lc($letter);
	return scalar(grep {$_->get() eq $letter} @{$self->{tiles}});
}

# Returns and removes a tile of the chosen letter type from the rack, or returns undef if there
# is no such tile.
# If $remove_blank is true, attempts to remove a blank tile from the rack if a given letter can't be found.
sub remove {
	my ($self, $letter, $remove_blank) = @_;
	
	$letter = lc($letter);
	my $tiles = $self->{tiles};
	for my $index (0..$#$tiles) {
		return splice(@$tiles, $index, 1) if $tiles->[$index]->get() eq $letter;
	}

	if ($remove_blank) {
		return $self->remove("*");
	}

	return undef;
}

# Returns the number of tiles currently in the rack.
sub size {
	my ($self) = @_;
	
	return scalar(@{$self->{tiles}});
}

# Returns the total value of the tiles in the rack.
sub value {
	my ($self) = @_;

	my $total = 0;
	for my $tile (@{$self->{tiles}}) {
		$total += $tile->get_value();
	}

	return $total;
}

# Returns a string representation of this Rack
sub str {
	my ($self) = @_;
	
	my $s = '';
	for my $tile (@{$self->{tiles}}) {
		$s .= $tile->get();
	}
	
	return $s;
}

1;
