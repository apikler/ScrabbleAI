##########################################################################
# ScrabbleAI::GUI::Board
# Canvas element that displays the game board
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

package ScrabbleAI::GUI::Board;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use ScrabbleAI::GUI::Space::BoardSpace;

use Data::Dumper;

sub new {
	my ($class, $board, @args) = @_;
	
	my $self = $class->SUPER::new(@args);
	bless($self, $class);
	
	$self->{board} = $board;
	
	# Initialize the spaces, but don't display them
	$self->{spaces} = {};
	$board->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$self->{spaces}{"$i,$j"} = ScrabbleAI::GUI::Space::BoardSpace->new($self, $space);
	});
	
	return $self;
}

# Iterates through each ScrabbleAI::GUI::Space on the board, and calls $sub with the following
# arguments for each ScrabbleAI::GUI::Space:
#	$space - the ScrabbleAI::GUI::Space
#	$i - i (horizontal) coordinate, from 0 to 14
#	$j - j (vertical) coordinate
sub foreach_space {
	my ($self, $sub) = @_;

	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;

		&$sub($self->get_space($i, $j), $i, $j);
	});
}

# Returns the ScrabbleAI::GUI::Space at the given coordinates
sub get_space {
	my ($self, $i, $j) = @_;

	return $self->{spaces}{"$i,$j"};
}

# Adds the current move to the board.
sub commit_spaces {
	my ($self) = @_;

	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;

		$space->commit();
	});
}

# Takes a Move and creates the necessary tiles on the board.
sub move_to_board {
	my ($self, $move) = @_;

	my $move_tiles = $move->get_tiles();
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;

		my $move_tile = $move_tiles->{"$i,$j"};
		if (!$space->has_tile() && $move_tile) {
			$space->create_tile($move_tile);
		}
	});
}

# Refreshes the image of the board drawn on the ScrabbleAI::GUI::Canvas
sub draw {
	my ($self, $side) = @_;
	
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$space->draw($i*$side, $j*$side, $side);
	});
}

1;
