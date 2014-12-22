package Rack;

use strict;
use warnings;

use Tile;

sub new {
	my ($class) = @_;
	
	my $self = bless({
		tiles => [],
	}, $class);
	
	return $self;
}

sub add_tile {
	my ($self, $tile) = @_;
	
	push(@{$self->{tiles}}, $tile);
}

# Returns an arrayref of the Tiles in this rack.
sub get_tiles {
	my ($self) = @_;

	my @tiles = @{$self->{tiles}};
	return \@tiles;
}

sub set_tiles {
	my ($self, $tiles) = @_;

	my @tiles_copy = @$tiles;
	$self->{tiles} = \@tiles_copy;
}

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

sub str {
	my ($self) = @_;
	
	my $s = '';
	for my $tile (@{$self->{tiles}}) {
		$s .= $tile->get();
	}
	
	return $s;
}

1;
