##########################################################################
# Backend::Board
# An internal representation of the game board.
#
# The coordinates on the board are as follows: The upper left square has
# coordinates 0,0 and coordinates increase down and to the right. The
# coordinates are often referred to as $i and $j, respectively, with $i
# going horizontally and $j going vertically. The coordinate
# 4 spaces to the right and 2 down from 0,0 is at 4,2.
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

package Backend::Board;

use strict;
use warnings;

use Data::Dumper;

use Backend::Space;
use Backend::Tile;

sub new {
	my ($class) = @_;
	
	my $self = bless({}, $class);
	$self->reset();
	
	return $self;
}

# Resets the board to its starting state. Creates blank Spaces with appropriate
# bonuses.
sub reset {
	my ($self) = @_;

	# The bonuses and their locations on the board
	my %bonuses_by_type = (
		'3W' => [
			'0,0',
			'7,0',
			'14,0',
			'14,7',
			'14,14',
			'7,14',
			'0,14',
			'0,7',
		],
		'2W' => [
			'7,7',
			'1,1',
			'2,2',
			'3,3',
			'4,4',
			'13,1',
			'12,2',
			'11,3',
			'10,4',
			'13,13',
			'12,12',
			'11,11',
			'10,10',
			'1,13',
			'2,12',
			'3,11',
			'4,10',
		],
		'3L' => [
			'5,1',
			'9,1',
			'1,5',
			'5,5',
			'9,5',
			'13,5',
			'1,9',
			'5,9',
			'9,9',
			'13,9',
			'5,13',
			'9,13',
		],
		'2L' => [
			'3,0',
			'11,0',
			'6,2',
			'8,2',
			'0,3',
			'7,3',
			'14,3',
			'2,6',
			'6,6',
			'8,6',
			'12,6',
			'3,7',
			'11,7',
			'2,8',
			'6,8',
			'8,8',
			'12,8',
			'0,11',
			'7,11',
			'14,11',
			'6,12',
			'8,12',
			'3,14',
			'11,14',
		],
	);
	
	my %bonuses_by_space;
	for my $bonus_type (keys %bonuses_by_type) {
		for my $space (@{$bonuses_by_type{$bonus_type}}) {
			$bonuses_by_space{$space} = $bonus_type;
		}
	}
	
	my %spaces = ();
	
	for my $i (0..14) {
		for my $j (0..14) {
			my $space = "$i,$j";
			my $bonus = $bonuses_by_space{$space};
			$spaces{$space} = $bonus ? Backend::Space->new($i, $j, $bonus) : Backend::Space->new($i, $j, '');
		}
	}

	$self->{spaces} = \%spaces;
	$self->{transposed} = 0;
}

# Returns the space at the given coordinates
sub get_space {
	my ($self, $i, $j) = @_;
	
	return $self->{spaces}{"$i,$j"};
}

# Takes a function and iterates through all the Spaces on the Board, calling
# that function for each space with the coordinates of the space as arguments.
# The function should look like this:
# sub {
#	my ($i, $j) = @_;
#   ...
# }
sub foreach_space {
	my ($self, $sub) = @_;
	
	for my $j (0..14) {
		for my $i (0..14) {
			&$sub($self->get_space($i, $j), $i, $j);
		}
	}
}

# Switches the Board's i and j coordinates. Across words become down words,
# and vice versa.
sub transpose {
	my ($self) = @_;
	
	my %newspaces;
	while (my ($index, $space) = each %{$self->{spaces}}) {
		$index =~ /(\d+)\,(\d+)/;
		$newspaces{"$2,$1"} = $space;
	}
	
	$self->{spaces} = \%newspaces;
	$self->{transposed} = $self->{transposed} ? 0 : 1;
}

# Returns 1 if the Board is currently transposed (see $self->transpose())
# or 0 if it is not.
sub is_transposed {
	my ($self) = @_;
	
	return $self->{transposed};
}

# Gets an arrayref of the tiles, in word order, on the board in the given direction
# (not including the actual tile specified by $i and $j).
# The direction is specified by $di and $dj.
# Example:
# The row is . . A N .  , and the index of the empty space after the N is 4,7.
# Calling $self->get_tiles_in_direction(4, 7, -1, 0) would return [Tile(A), Tile(N)]
# Calling $self->get_tiles_in_direction(1, 7, 1, 0) would return the same thing.
# One of $di or $dj must be 1 or -1; the other value must be 0. Otherwise the result is undefined
# and bad things may happen.
sub get_tiles_in_direction {
	my ($self, $i, $j, $di, $dj) = @_;
	
	my @result;
	$i += $di;
	$j += $dj;
	my $space = $self->get_space($i, $j);
	
	while ($space && (my $tile = $space->get_tile())) {		
		if ($di + $dj == 1) {
			push (@result, $tile);
		}
		elsif ($di + $dj == -1) {
			unshift (@result, $tile);
		}
		$i += $di;
		$j += $dj;
		$space = $self->get_space($i, $j);
	}
	
	return \@result;
}

# Places tiles corresponding to the word (a string) starting at $i, $j.
# Word is placed down if $down is true, otherwise across.
# Does not consider any tiles that may already be on the board. For testing only.
sub place_word {
	my ($self, $word, $i, $j, $down) = @_;
	
	my @letters = split('', $word);
	my $index = 0;
	while ((my $space = $self->get_space($i, $j)) && $index < @letters) {
		$space->set_tile(Backend::Tile->new($letters[$index]));
		if ($down) {
			$j++;
		}
		else {
			$i++;
		}
		$index++;
	}
}

# Returns an arrayref of the 2 to 4 adjacent spaces to the one at $i, $j.
sub adjacent_spaces {
	my ($self, $i, $j) = @_;
	
	my $changes = get_directions();
	
	my @adjacencies;
	for my $change (@$changes) {
		my $di = $change->[0];
		my $dj = $change->[1];
		my $space = $self->get_space($i + $di, $j + $dj);
		push (@adjacencies, $space) if $space;
	}
	
	return \@adjacencies;
}

sub get_directions {
	return [
		[0, 1],
		[0, -1],
		[1, 0],
		[-1, 0],
	];
}

# Returns the number of spaces on each side of the (square) board
sub get_width {
	my ($self) = @_;
	
	return 15;
}

sub in_bounds {
	my ($self, $i, $j) = @_;
	
	my $width = $self->get_width();
	return $i >= 0 && $j >= 0 && $i < $width && $j < $width;
}

# Prints a human-readable representation of the bonuses on the board.
# Doesn't print any tiles that may be on the board.
sub print_bonuses {
	my ($self) = @_;
	
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;
		my $bonus = $space->get_bonus();
		print $bonus ? "$bonus " : '** ';
		print "\n" if $i == 14;
	});
}

sub print_spaces {
	my ($self) = @_;
	
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;
		$space->print();
		print ' ';
		print "\n" if $i == 14;
	});
}

# Commits the given Move to the board, adding the Tiles to the corresponding coordinates.
sub make_move {
	my ($self, $move) = @_;
	
	while (my ($location, $tile) = each %{$move->get_tiles()}) {
		$location =~ /(\d+)\,(\d+)/;
		my ($i, $j) = ($1, $2);
		
		$self->get_space($i, $j)->set_tile($tile);
	}
}

# Returns hashref of {"$i,$j" => Space} for each space that is adjacent to at least one other tile
# and is itself empty;
sub get_anchors {
	my ($self) = @_;

	my %anchors;
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;

		# This space can't be an anchor because it isn't empty.
		return if $space->get_tile();

		my $neighbors = $self->adjacent_spaces($i, $j);
		for my $neighbor (@$neighbors) {
			if ($neighbor->get_tile()) {
				$anchors{"$i,$j"} = $space;
				last;
			}
		}
	});

	# If at this point we have no anchors, that means there are no tiles on the board. So make
	# the middle space on the board an anchor
	$anchors{'7,7'} = $self->get_space(7, 7) unless keys %anchors;

	return \%anchors;
}

1;
