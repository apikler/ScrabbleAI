##########################################################################
# Backend::Player::AIPlayer
# Handles the automatic move generation.
# To further understand how move generation works, especially left_part()
# and extend_right(), please refer to:
# "The World's Fastest Scrabble Program", by Andrew W. Appel and Guy J.
# Jacobson, published May 1988.
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

package Backend::Player::AIPlayer;
use base qw(Backend::Player);

use strict;
use warnings;

use Data::Dumper;
use POSIX;

use Backend::Tile;
use Backend::Move;
use Backend::Node;

sub new {
	my ($class, $board, $library) = @_;
	
	my $self = Backend::Player->new($board);
	
	bless($self, $class);
	$self->{library} = $library;
	$self->{difficulty} = 10; # Default difficulty

	return $self;
}

# Returns the total number of possible difficulty settings for the AI.
sub num_difficulties {
	return 10;
}

# Sets the difficulty of this player. Valid difficulties are integer values
# from 1 to 10, with 10 being the hardest.
sub set_difficulty {
	my ($self, $difficulty) = @_;

	$self->{difficulty} = $difficulty;
}

sub get_difficulty {
	my ($self) = @_;
	return $self->{difficulty};
}

# Given the current board state, returns the move the AI Player wants to make.
# This works by generating and evaluating all the possible moves, and then picking
# one that is appropriate for the difficulty that has been set.
sub get_move {
	my ($self) = @_;
	
	# Save the tiles currently held by the AI for use in save_move
	my @tiles = @{$self->{rack}->get_tiles()};
	$self->{all_tiles} = \@tiles;
	
	$self->{moves} = [];
	$self->get_moves();
	my @across_moves = @{$self->{moves}};
	
	$self->{moves} = [];
	$self->{board}->transpose();
	$self->get_moves();
	map {$_->transpose()} @{$self->{moves}};
	my @down_moves = @{$self->{moves}};
	$self->{board}->transpose();
	
	my @moves = sort {$b->{value} <=> $a->{value}} (@across_moves, @down_moves);	
	
	return undef unless scalar @moves;

	return $self->pick_move_from_difficulty(\@moves);
}

# Given an arrayref of $moves sorted in order of decreasing value, selects an appropriate
# one based on the difficulty setting.
sub pick_move_from_difficulty {
	my ($self, $moves) = @_;

	return undef unless scalar @$moves;

	my $num_difficulties = $self->num_difficulties();
	my $difficulty = $num_difficulties - $self->{difficulty};

	# An array containing the values of the moves in decreasing order, with one
	# entry per value.
	my @move_values = ($moves->[0]{value});
	for my $move (@$moves) {
		push(@move_values, $move->{value}) if $move_values[-1] != $move->{value};
	}

	my $multiplier = floor(@move_values / $num_difficulties) || 1;
	my $index = $difficulty * $multiplier;
	if ($index > $#move_values) {
		$index = $#move_values
	}

	my $value = $move_values[$index];
	my @move_choices = grep {$_->{value} == $value} @$moves;

	# Sort the move choices by the move length to favor longer moves.
	@move_choices = sort { $b->length() <=> $a->length() } @move_choices;

	return $move_choices[0];
}

# Returns an arrayref of all the legal horizontal moves the AI can make,
# sorted in order of decreasing value. As this only gets horizontal moves,
# to get all the possible moves the board must be transposed and then this
# must be called again.
sub get_moves {
	my ($self) = @_;
	
	my $anchors = $self->{board}->get_anchors();
	my $restrictions = $self->get_restrictions();
	
	while (my ($location, $anchor) = each %$anchors) {
		$location =~ /(\d+)\,(\d+)/;
		my ($i, $j) = ($1, $2);
						
		my $root = $self->{library}->get_tree();
		# Get the "prefix", i.e. the tiles on the board to the left of this anchor
		my $prefix_tiles = $self->{board}->get_tiles_in_direction($i, $j, -1, 0);
		if (@$prefix_tiles) {
			my @prefix = map {$_->get()} @$prefix_tiles;
			my $node = Backend::Node::get_node($root, @prefix);
			if ($node) {
				$self->extend_right(join('', @prefix), $node, $restrictions, $i, $j);
			}
		}
		else {
			# Backtrack to find the number of spaces before an anchor to the left of $i, $j
			my $limit = 0;
			my $new_i = $i;
			while (1) {
				$new_i--;
				if ($self->{board}->in_bounds($new_i, $j) && !defined($anchors->{"$new_i,$j"})) {
					$limit++;
				}
				else {
					last;
				}
			}
			
			$self->left_part('', $root, $limit, $restrictions, $i, $j);
		}
	}
}

# Recursively generates playable words horizontally, anchored at the coordinates $i, $j.
#	$partial_word: The letters that we've tried placing to the left of this tile to form
#		the beginning of the word (NOTE: these are not tiles already on the board; they are
#		just various possibilities we are trying)
#	$node: The current Node we are at in the word tree. This will have children that correspond
#		to the next letter we can play to the right
#	$limit: An integer corresponding to the amount of room to the left of this letter before we hit
#		another anchor
#	$restrictions: An arrayref of allowed letters at this anchor, based on the vertically adjacent
#		tiles. Can be empty if all letters are allowed.
sub left_part {
	my ($self, $partial_word, $node, $limit, $restrictions, $i, $j) = @_;
	
	# Given this left part, attempt to extend the word to the right from this anchor.
	$self->extend_right($partial_word, $node, $restrictions, $i, $j);

	if ($limit > 0) {
		for my $letter (@{$node->get_edges()}) {
			my $tile;
			# Attempt to place a non-blank tile first; otherwise resort to using the blank
			if ($self->{rack}->contains($letter)) {
				$tile = $self->{rack}->remove($letter);
			}
			elsif ($self->{rack}->contains('*')) {
				$tile = $self->{rack}->remove('*');
			}
			
			if ($tile) {
				$self->left_part(
					$partial_word . $letter,
					$node->get_child($letter),
					$limit - 1,
					$restrictions,
					$i,
					$j,
				);
				$self->{rack}->add_tile($tile);
			}
		}
	}
}

# This is called at various times during move generation when a valid move is found. It creates
# a new Move that is then saved for use in $self->get_moves().
sub save_move {
	my ($self, $word, $i, $j) = @_;
	
	my $move = Backend::Move->new($self->{board});
	$move->set_word_reverse($word, $i, $j, $self->{all_tiles});
	$move->evaluate();
	push(@{$self->{moves}}, $move);
}

# Attempts to extend potential words to the right from the space at $i, $j.
#	$partial_word: The part of the potential word we are trying that lies to the left, from left_part()
#	$node: The current Node we are at in the word tree
#	$restrictions: An arrayref of allowed letters at this anchor, based on the vertically adjacent
#		tiles. Can be empty if all letters are allowed.
sub extend_right {
	my ($self, $partial_word, $node, $restrictions, $i, $j) = @_;

	my $board = $self->{board};
	return unless $board->in_bounds($i, $j);	# We have wandered off the edge of the board.
	
	my $board_tile = $board->get_space($i, $j)->get_tile();
	unless ($board_tile) {
		# If there's no tile on the board here ($i, $J), then try and see, for each letter of
		# the rack, if there's a corresponding child node of $node. If so, continue extending
		# right using that child node.
		#
		# If we've reached and end point in the tree, save the move.

		for my $letter (@{$node->get_edges()}) {
			my $tile;
			if ($self->{rack}->contains($letter)) {
				$tile = $self->{rack}->remove($letter);
			}
			elsif ($self->{rack}->contains('*')) {
				$tile = $self->{rack}->remove('*');
			}
			
			if ($tile && passes_restrictions($letter, $restrictions, $i, $j)) {
				my $child = $node->get_child($letter);
				if ($child->is_endpoint()) {
					my $space = $board->get_space($i+1, $j);
					if (!defined($space) || !($space->get_tile())) {
						$self->save_move($partial_word.$letter, $i, $j);
					}
				}
				$self->extend_right($partial_word.$letter, $child, $restrictions, $i+1, $j);
			}
			$self->{rack}->add_tile($tile) if $tile;
		}
	}
	else {
		# If we have a tile on the board at ($i, $j), see if that letter is a child of this node.
		# If so, we can keep extending to the right from it; if it's also an endpoint, we have a
		# valid word that we can save.

		my $letter = $board_tile->get();
		my $child = $node->get_child($letter);
		if ($child) {
			if ($child->is_endpoint()) {
				my $space = $board->get_space($i+1, $j);
				if (!defined($space) || !($space->get_tile())) {
					$self->save_move($partial_word.$letter, $i, $j);
				}
			}
			$self->extend_right($partial_word.$letter, $child, $restrictions, $i+1, $j);
		}
	}
}

# Cross-checks. Returns a hashref of
# {'i,j' => arrayref of allowed letters}
# where "allowed letters" is an arrayref of letters that can be placed
# in the space at i,j to create a legal word vertically.
# An empty arrayref means no tiles are allowed.
# A missing entry means any tiles are allowed.
sub get_restrictions {
	my ($self) = @_;
	
	my $letters = Backend::Tile::get_allowed_letters();
	my %restrictions;
	
	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;
		my $index = "$i,$j";
		
		# No need to calculate restrictions if this space has a tile.
		if ($space->get_tile()) {
			return;
		}
		
		my $top_tiles = $self->{board}->get_tiles_in_direction($i, $j, 0, -1);
		my $top_letters = join('', map {$_->get()} @$top_tiles);
		my $bottom_tiles = $self->{board}->get_tiles_in_direction($i, $j, 0, 1);
		my $bottom_letters = join('', map {$_->get()} @$bottom_tiles);
		
		if (length($top_letters.$bottom_letters) > 0) {
			# Cycle through all the valid letters to see which ones make a valid
			# word with the adjacent tiles
			
			my @restriction;
			for my $letter (@$letters) {
				if ($self->{library}->is_tree_word($top_letters.$letter.$bottom_letters)) {
					push (@restriction, $letter);
				}
			}
			
			$restrictions{$index} = \@restriction;
		}
	});
	
	return \%restrictions;
}

# Returns 1 if $letter is OK to place at $i, $j, given $restrictions as generated
# by get_restrictions. 
sub passes_restrictions {
	my ($letter, $restrictions, $i, $j) = @_;
	
	return 1 if $letter eq '*';
	
	return 1 unless defined $restrictions->{"$i,$j"};
	my $restriction = $restrictions->{"$i,$j"};
	
	for my $allowed (@$restriction) {
		return 1 if $allowed eq $letter;
	}
	
	# print "$letter at $i, $j is not allowed!\n";
	return 0;
}


1;
