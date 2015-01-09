package Backend::Bag;

use strict;
use warnings;

use Backend::Tile;

my %amounts = (
	A => 9,
	B => 2,
	C => 2,
	D => 4,
	E => 12,
	F => 2,
	G => 3,
	H => 2,
	I => 9,
	J => 1,
	K => 1,
	L => 4,
	M => 2,
	N => 6,
	O => 8,
	P => 2,
	Q => 1,
	R => 6,
	S => 4,
	T => 6,
	U => 4,
	V => 2,
	W => 2,
	X => 1,
	Y => 2,
	Z => 1,
	'*' => 2,
);

sub new {
	my ($class) = @_;
	
	my $self = bless({
		tiles => [],
	}, $class);
	
	$self->reset();
	
	return $self;
}

sub reset {
	my ($self) = @_;
	
	$self->{tiles} = [];

	for my $type (keys %amounts) {
		for my $i (1..$amounts{$type}) {
			push(@{$self->{tiles}}, Backend::Tile->new($type));
		}
	}
}

# Adds the given tile to the bag.
sub add {
	my ($self, $tile) = @_;

	$tile->set_on_board(0);
	$tile->clear_location();

	push(@{$self->{tiles}}, $tile);
}

sub count {
	my ($self) = @_;
	
	return scalar(@{$self->{tiles}});
}

# Remove and return a Tile from the Bag. Returns undef if the bag is empty.
sub draw {
	my ($self) = @_;
	
	return undef unless $self->count();
	
	my $index = int(rand($self->count()));
	
	return scalar(splice(@{$self->{tiles}}, $index, 1));
}

1;
