package Space;

use strict;
use warnings;

sub new {
	my ($class, $bonus) = @_;
	
	my $self = bless({
		bonus => $bonus,
		tile => undef,
	}, $class);
	
	return $self;
}

sub get_tile {
	my $self = @_;
	
	return $self->{tile};
}

sub set_tile {
	my ($self, $tile) = @_;
	
	$self->{tile} = $tile;
}

sub get_bonus {
	my ($self) = @_;
	
	return $self->{bonus};
}

sub print {
	my ($self) = @_;
	
	print $self->{tile} ? $self->{tile}->get() : '.';
}

1;
