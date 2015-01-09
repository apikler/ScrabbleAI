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

sub set_difficulty {
	my ($self, $difficulty) = @_;

	$self->{difficulty} = $difficulty;
}

sub get_difficulty {
	my ($self) = @_;
	return $self->{difficulty};
}

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

# Returns an arrayref of all the legal moves the AI can make, sorted in order of decreasing value
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

sub left_part {
	my ($self, $partial_word, $node, $limit, $restrictions, $i, $j) = @_;
	# print "left part limit: $limit, partial word: $partial_word \n";
	# print "rack: " . $self->{rack}->str() ."\n";
	
	$self->extend_right($partial_word, $node, $restrictions, $i, $j);
	if ($limit > 0) {
		for my $letter (@{$node->get_edges()}) {
			#print "letter: $letter \n";
			#print "rack: " . $self->{rack}->str() ."\n";
			my $tile;
			if ($self->{rack}->contains($letter)) {
				$tile = $self->{rack}->remove($letter);
			}
			elsif ($self->{rack}->contains('*')) {
				$tile = $self->{rack}->remove('*');
			}
			# print "rack after: " . $self->{rack}->str() ."\n";
			
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

sub save_move {
	my ($self, $word, $i, $j) = @_;
	
	my $move = Backend::Move->new($self->{board});
	$move->set_word_reverse($word, $i, $j, $self->{all_tiles});
	$move->evaluate();
	push(@{$self->{moves}}, $move);
}

sub extend_right {
	my ($self, $partial_word, $node, $restrictions, $i, $j) = @_;

	my $board = $self->{board};
	return unless $board->in_bounds($i, $j);
	
	my $board_tile = $board->get_space($i, $j)->get_tile();
	unless ($board_tile) {
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
