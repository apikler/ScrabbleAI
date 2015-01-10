##########################################################################
# ScrabbleAI::Backend::Player
# Representation of a player in the game; has a Rack with tiles, and has
# a score.
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

package ScrabbleAI::Backend::Player;

use strict;
use warnings;

use Data::Dumper;

use ScrabbleAI::Backend::Tile;
use ScrabbleAI::Backend::Rack;

sub new {
	my ($class, $board) = @_;
	
	my $self = bless({
		board => $board,
		rack => ScrabbleAI::Backend::Rack->new(),
		score => 0,
	}, $class);
	
	return $self;
}

# Resets this Player to a starting state
sub reset {
	my ($self) = @_;

	$self->{score} = 0;
	$self->{rack}->empty();
}

# Fills the player's rack up to 7 tiles. If there are less than that many
# tiles remaining in the bag, all of them are drawn.
sub draw_hand {
	my ($self, $bag) = @_;
	
	my $handsize = $self->{rack}->size();
	# The number of tiles to draw to get to a rack of 7:
	my $todraw = 7 - $handsize;
	# If there aren't enough tiles in the bag:
	my $bagcount = $bag->count();
	$todraw = $bagcount if $bagcount < $todraw;
	
	for my $i (1..$todraw) {
		$self->{rack}->add_tile($bag->draw());
	}
}

# Returns this player's Rack.
sub get_rack {
	my ($self) = @_;

	return $self->{rack};
}

# Increments the player's score by the given amount.
sub increment_score {
	my ($self, $amount) = @_;

	$self->{score} += $amount;
}

# Returns this Player's current score.
sub get_score {
	my ($self) = @_;

	return $self->{score};
}

1;
