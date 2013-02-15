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
sub remove {
	my ($self, $letter) = @_;
	
	$letter = lc($letter);
	my $tiles = $self->{tiles};
	for my $index (0..$#$tiles) {
		return splice(@$tiles, $index, 1) if $tiles->[$index]->get() eq $letter;
	}
	
	return undef;
}

# Returns the number of tiles currently in the rack.
sub size {
	my ($self) = @_;
	
	return scalar(@{$self->{tiles}});
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
