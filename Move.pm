package Move;

use strict;
use warnings;

use Data::Dumper;

use List::Util qw(sum);

use Tile;
use Board;
use Utils;
use Rack;

sub new {
	my ($class, $board) = @_;
	
	my $self = bless({
		tiles => {},	# Hashref of 'i,j' => Tile being placed
		board => $board,
		value => 0,
		transposed => 0,
	}, $class);
	
	return $self;
}

# If this move has a tile to be placed at coordinates (i, j), remove that
# from this move.
sub remove {
	my ($self, $i, $j) = @_;

	$self->{tiles}{"$i,$j"}->clear_location();
	delete $self->{tiles}{"$i,$j"};
}

sub add {
	my ($self, $i, $j, $tile) = @_;

	$tile->set_location($i, $j);
	$self->{tiles}{"$i,$j"} = $tile;
}

# sub set_word {
# 	my ($self, $word, $i, $j, $down) = @_;
#
# 	my ($di, $dj) = $down ? (0, 1) : (1, 0);
# 	my $index = 0;
# 	while ($self->{board}->in_bounds($i, $j) && $index < length($word)) {
# 		my $tile_on_board = $self->{board}->get_space($i, $j)->get_tile();
# 		unless ($tile_on_board) {
# 			my $tile = Tile->new(substr($word, $index, 1));
# 			$self->{tiles}{"$i,$j"} = $tile;
# 			$tile->set_location($i, $j);
# 		}
# 		$i += $di;
# 		$j += $dj;
# 		$index++;
# 	}
# }

# Sets this move such that it creates the given word horizontally, ending at $i, $j.
# If $tiles is an arrayref of tiles, attempts to use copies of those tiles, and uses
# a blank tile if a given tile doesn't exist in $tiles.
sub set_word_reverse {
	my ($self, $word, $i, $j, $tiles) = @_;
	
	my $rack; # Dummy rack to use if $tiles has been set.
	if ($tiles) {
		$rack = Rack->new();
		$rack->set_tiles($tiles);
	}

	my ($di, $dj) = (-1, 0);
	my $index = length($word) - 1;
	while ($self->{board}->in_bounds($i, $j) && $index >= 0) {
		my $tile_on_board = $self->{board}->get_space($i, $j)->get_tile();
		unless ($tile_on_board) {
			my $letter = substr($word, $index, 1);
			my $tile;
			if ($rack) {
				if ($rack->remove($letter)) {
					# This letter is in $tiles, so use a normal tile
					$tile = Tile->new($letter);
				}
				else {
					# The letter is not in $tiles, so use a blank tile.
					$rack->remove("*");
					$tile = Tile->new("*");
					$tile->set_blank_letter($letter);
				}
			}
			else {
				$tile = Tile->new($letter);
			}


			$self->{tiles}{"$i,$j"} = $tile;
			if ($self->{board}->is_transposed()) {
				$tile->set_location($j, $i);
			}
			else {
				$tile->set_location($i, $j);
			}
		}
		$i += $di;
		$j += $dj;
		$index--;
	}
}

sub evaluate {
	my ($self) = @_;

	my $total_score = 0;
	for my $tiles (@{$self->get_word_tiles()}) {
		my $word_score = 0;
		my $multiplier = 1;
		for my $tile (@$tiles) {
			my ($i, $j) = @{Utils::split_coord($tile->get_location())};
			my $bonus = $self->{board}->get_space($i, $j)->get_bonus();

			# If the tile is on the board already, we don't care about the bonus underneath.
			if ($tile->is_on_board() || !$bonus) {
				$word_score += $tile->get_value();
			}
			else {
				my $b_value = substr($bonus, 0, 1);
				my $b_type = substr($bonus, 1, 1);

				if ($b_type eq 'L') {
					$word_score += $tile->get_value() * $b_value;
				}
				else {
					$multiplier *= $b_value;
					$word_score += $tile->get_value();
				}
			}
		}

		$total_score += $word_score * $multiplier;
	}

	# 50 point bonus if all 7 tiles are used
	$total_score += 50 if keys %{$self->{tiles}} == 7;

	$self->{value} = $total_score;
	return $total_score;
}

sub get_tiles {
	my ($self) = @_;
	
	return $self->{tiles};
}

# Switches the move's i and j coordinates.
sub transpose {
	my ($self) = @_;
	
	my %newtiles;
	while (my ($index, $tile) = each %{$self->{tiles}}) {
		$index =~ /(\d+)\,(\d+)/;
		$newtiles{"$2,$1"} = $tile;
	}
	
	$self->{tiles} = \%newtiles;

	$self->{transposed} = $self->{transposed} ? 0 : 1;
}

# Returns 1 if this Move contains at least one anchor (as returned by Board),
# 0 otherwise.
sub contains_anchor {
	my ($self) = @_;

	my $anchors = $self->{board}->get_anchors();

	foreach my $coords (keys %{$self->{tiles}}) {
		return 1 if defined $anchors->{$coords};
	}

	return 0;
}

# Returns 1 if all the tiles in this move make a straight line, possibly
# with other tiles already on the board, 0 otherwise.
sub straight_line {
	my ($self) = @_;

	my $numtiles = scalar(keys %{$self->{tiles}});
	return 0 if $numtiles == 0;
	return 1 if $numtiles == 1;

	my $straight = 0;
	foreach my $n (0..1) {
		my @coords = keys %{$self->{tiles}};
		my @coords_i = Utils::coord_position(\@coords, 0);
		my @coords_j = Utils::coord_position(\@coords, 1);

		# We want to set $straight to 1 if all the j-coordinates are the same
		# and there are no empty spaces between the leftmost and rightmost
		# tile of this move.
		if (Utils::same_elements(\@coords_j)) {
			my $j = $coords_j[0];

			my $problem = 0;	# There's an empty space, or one of the move spaces already has a tile.
			my @sorted_i = sort {$a <=> $b} @coords_i;
			foreach my $i ($sorted_i[0]..$sorted_i[$#sorted_i]) {
				$problem = 1 unless $self->{tiles}{"$i,$j"} xor $self->{board}->get_space($i, $j)->get_tile();
			}

			$straight = 1 if $problem == 0;
		}

		# We only considered horizontal moves, now we need to consider vertical moves.
		$self->transpose();
		$self->{board}->transpose();
	}

	return $straight;
}

sub legal {
	my ($self) = @_;

	return $self->contains_anchor() && $self->straight_line();
}

# Returns "h" or "v" depending on whether this move is horizontal or vertical.
# Returns undef if the move is empty.
# Warning: result is undefined if the move is not in a straight line.
sub get_direction {
	my ($self) = @_;

	my @locations = keys %{$self->{tiles}};
	return undef unless scalar @locations;

	my $direction;
	if (@locations > 1) {
		# Use the first two locations in determining the direction.
		my $i0 = Utils::split_coord($locations[0])->[0];
		my $i1 = Utils::split_coord($locations[1])->[0];

		if ($i0 == $i1) {
			return 'v';
		}
		else {
			return 'h';
		}
	}
	else {
		# If there's only one tile, check the surrounding tiles on the board
		# and decide accordingly.
		my ($i, $j) = @{Utils::split_coord($locations[0])};
		my $left_tiles = scalar @{$self->{board}->get_tiles_in_direction($i, $j, -1, 0)};
		my $right_tiles = scalar @{$self->{board}->get_tiles_in_direction($i, $j, 1, 0)};

		if ($left_tiles + $right_tiles) {
			return 'h';
		}
		else {
			return 'v';
		}
	}
}

# Returns an array of the locations of the tiles in this move, sorted
# from left to right or top to bottom.
sub get_sorted_locations {
	my ($self) = @_;

	my $direction = $self->get_direction();
	return () unless $direction;

	my @locations = keys %{$self->{tiles}};

	if ($direction eq 'h') {
		# Want to sort by the i coordinate
		return sort { Utils::split_coord($a)->[0] <=> Utils::split_coord($b)->[0] } @locations;
	}
	else {
		# Sort by the j coordinate
		return sort { Utils::split_coord($a)->[1] <=> Utils::split_coord($b)->[1] } @locations;
	}
}

# Returns an arrayref of arrays, each of which consists of tiles, in order,
# that make up words created by this move. These words may include tiles that
# were already on the board. The words are not necessarily valid words.
# Returns the empty array if move is not legal.
sub get_word_tiles {
	my ($self) = @_;

	return [] unless $self->legal();

	# To simplify things, transpose everything if the move is vertical.
	my $orig_direction = $self->get_direction();
	if ($orig_direction eq 'v') {
		$self->transpose();
		$self->{board}->transpose();
	}

	my @words;
	my @locations = $self->get_sorted_locations();
	my $board = $self->{board};

	# Consider the horizontal word (the "main word") formed by this move
	my ($i_min, $j) = @{Utils::split_coord($locations[0])};
	my $i_max = Utils::split_coord($locations[-1])->[0];
	my @h_word = @{$board->get_tiles_in_direction($i_min, $j, -1, 0)};
	for my $i ($i_min..$i_max) {
		# If this position is part of this move, use the tile from the move. Otherwise, there should
		# already be a tile here on the board, so use that.
		if (exists $self->{tiles}{"$i,$j"}) {
			push(@h_word, $self->{tiles}{"$i,$j"});
		}
		else {
			push(@h_word, $board->get_space($i, $j)->get_tile());
		}
	}

	push(@h_word, @{$board->get_tiles_in_direction($i_max, $j, 1, 0)});
	push(@words, \@h_word) if @h_word >= 1;

	# Consider all the vertical cross-words
	for my $location (@locations) {
		my ($i, $j) = @{Utils::split_coord($location)};
		my @v_word = (
			@{$board->get_tiles_in_direction($i, $j, 0, -1)},
			$self->{tiles}{$location},
			@{$board->get_tiles_in_direction($i, $j, 0, 1)},
		);

		# If this is actually a word (more than 1 character) push it onto the end result
		push(@words, \@v_word) if @v_word > 1;
	}

	if ($orig_direction eq 'v') {
		$self->transpose();
		$self->{board}->transpose();
	}

	return \@words;
}

# Returns an arrayref containing the word(s) created by this move, as strings. The words
# are not necessarily valid.
# Empty if the move is not legal.
sub get_words {
	my ($self) = @_;

	my @words;
	for my $tiles (@{$self->get_word_tiles()}) {
		my $word = '';
		for my $tile (@$tiles) {
			$word .= $tile->get();
		}
		push(@words, $word);
	}

	return \@words;
}

# Returns 1 if the move contains at least one blank tile whose letter has not been set.
# Returns 0 otherwise.
sub contains_unset_blank {
	my ($self) = @_;

	for my $tile (values %{$self->{tiles}}) {
		if ($tile->is_blank() && $tile->get() eq '*') {
			return 1;
		}
	}

	return 0;
}

sub str {
	my ($self) = @_;

	my @strings;
	while (my ($location, $tile) = each %{$self->{tiles}}) {
		my $letter = $tile->get();
		push(@strings, "($location) => '$letter'");
	}

	return join(' ; ', @strings);
}

1;
