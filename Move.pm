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
	}

	return $straight;
}

sub legal {
	my ($self) = @_;

	return $self->contains_anchor() && $self->straight_line();
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
