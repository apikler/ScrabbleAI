package Tile;

use strict;
use warnings;

my %values = (
	A => 1,
	B => 3,
	C => 3,
	D => 2,
	E => 1,
	F => 4,
	G => 2,
	H => 4,
	I => 1,
	J => 8,
	K => 5,
	L => 1,
	M => 3,
	N => 1,
	O => 1,
	P => 3,
	Q => 10,
	R => 1,
	S => 1,
	T => 1,
	U => 1,
	V => 4,
	W => 4,
	X => 8,
	Y => 4,
	Z => 10,
	'*' => 0,
);

sub new {
	my ($class, $type) = @_;
	
	my $self = bless({
		# The type is the kind of tile this is; a lower-case letter, or * if it's a blank.
		type => lc($type),
		value => $values{uc($type)},
		# The letter is the actual letter this tile represents on the board; for non-blank tiles
		# this is the same as the type. For blanks, this is * until set_blank_letter is called.
		letter => lc($type),
		on_board => 0, # Flag that indicates whether this tile has been placed on the board.
		location => '', # Coordinates of this tile
	}, $class);
	
	return $self;
}

sub get_value {
	my ($self) = @_;
	
	return $self->{value};
}

# Returns the letter of this tile in lower case.
sub get {
	my ($self) = @_;
	
	return $self->{letter};
}

sub set_on_board {
	my ($self, $on_board) = @_;
	$self->{on_board} = $on_board;
}

sub is_on_board {
	my ($self) = @_;
	return $self->{on_board};
}

sub set_location {
	my ($self, $i, $j) = @_;
	$self->{location} = "$i,$j";
}

sub clear_location {
	my ($self) = @_;
	$self->{location} = '';
}

sub get_location {
	my ($self) = @_;
	return $self->{location};
}

# If this tile is a blank, sets the letter. Otherwise, does nothing.
sub set_blank_letter {
	my ($self, $letter) = @_;
	
	$self->{letter} = lc($letter) if $self->is_blank();
}

sub is_blank {
	my ($self) = @_;
	
	return $self->{type} eq '*';
}

# Returns an arrayref of allowed letters based on %values above.
# (This is the keys of %values, lower case, without the '*')
sub get_allowed_letters {
	my @letters = map {lc($_)} grep {$_ ne '*'} keys %values;
	return \@letters;
}

1;
