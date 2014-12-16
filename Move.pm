package Move;

use strict;
use warnings;

use Data::Dumper;

use List::Util qw(sum);

use Tile;
use Board;
use Utils;

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

	delete $self->{tiles}{"$i,$j"};
}

sub add {
	my ($self, $i, $j, $tile) = @_;

	$self->{tiles}{"$i,$j"} = $tile;
}

sub set_word {
	my ($self, $word, $i, $j, $down) = @_;
	
	my ($di, $dj) = $down ? (0, 1) : (1, 0);
	my $index = 0;
	while ($self->{board}->in_bounds($i, $j) && $index < length($word)) {
		my $tile_on_board = $self->{board}->get_space($i, $j)->get_tile();
		unless ($tile_on_board) {
			$self->{tiles}{"$i,$j"} = Tile->new(substr($word, $index, 1));
		}
		$i += $di;
		$j += $dj;
		$index++;
	}
}

# TODO: Fix bug with putting blanks on board where they become actual letter tiles with values
sub set_word_reverse {
	my ($self, $word, $i, $j, $up) = @_;
	
	my ($di, $dj) = $up ? (0, -1) : (-1, 0);
	my $index = length($word) - 1;
	while ($self->{board}->in_bounds($i, $j) && $index >= 0) {
		my $tile_on_board = $self->{board}->get_space($i, $j)->get_tile();
		unless ($tile_on_board) {
			$self->{tiles}{"$i,$j"} = Tile->new(substr($word, $index, 1));
		}
		$i += $di;
		$j += $dj;
		$index--;
	}
}

sub evaluate {
	my ($self) = @_;
	
	my @multipliers;		# List of the "Double/Triple Word Score" bonuses under new tiles
	my $sum_on_board = 0;	# Sum of values of the relevant tiles on the board before the move
	my $new_sum = 0;		# Sum of values of the new tiles we're placing
	my %tiles_checked;		# Tiles on the board that we've already added to $sum_on_board
	while (my ($location, $tile) = each %{$self->{tiles}}) {
		$location =~ /(\d+)\,(\d+)/;
		my ($i, $j) = ($1, $2);
		
		# Get the sum of the values of the tiles already on the board that are connected to this
		# tile in the same row/column. Do not consider their bonuses
		my $directions = Board::get_directions();
		for my $d (@$directions) {
			my $tiles_on_board = $self->{board}->get_tiles_in_direction($i, $j, $d->[0], $d->[1]);
			for my $board_tile (@$tiles_on_board) {
				# Make sure we are not double-counting tiles on the board
				unless ($tiles_checked{$board_tile}) {
					$sum_on_board += $board_tile->get_value();
					$tiles_checked{$board_tile} = 1;
				}
			}
		}
		
		# Now add the value of the new tile being placed, including relevant bonuses.
		my $value = $tile->get_value();
		my $bonus = $self->{board}->get_space($i, $j)->get_bonus() =~ /(\d)([WL])/;
		if ($bonus) {
			my ($bonus_amount, $bonus_type) = ($1, $2);
			if ($bonus_type eq 'L') {
				$value *= $bonus_amount;
			}
			elsif ($bonus_type eq 'W') {
				push(@multipliers, $bonus_amount);
			}
		}
		$new_sum += $value;
	}
	
	# Multiply the sum of the new tile values by each Word Score bonus
	for my $multiplier (@multipliers) {
		$new_sum *= $multiplier;
	}
	
	# Total sum is score of tiles already on board + score of new tiles, including bonuses
	my $score = $sum_on_board + $new_sum;
	$self->{value} = $score;
	return $score;
}

sub get_value {
	my ($self) = @_;
	
	$self->evaluate() if $self->{value} == 0;
	return $self->{value};
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
		# If there's only one tile, the result is arbitrary.
		return 'h';
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

	return () unless $self->legal();

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
