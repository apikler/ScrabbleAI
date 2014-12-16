package Space;

use strict;
use warnings;

sub new {
	my ($class, $i, $j, $bonus) = @_;
	
	my $self = bless({
		bonus => $bonus,
		tile => undef,
		i => $i,
		j => $j,
	}, $class);
	
	return $self;
}

sub get_coords {
	my ($self) = @_;

	return ($self->{i}, $self->{j});
}

sub get_tile {
	my ($self) = @_;
	
	return $self->{tile};
}

sub set_tile {
	my ($self, $tile) = @_;
	
	if ($tile) {
		$tile->set_on_board(1);
		$tile->set_location($self->{i}, $self->{j});
	}
	else {
		$tile->set_on_board(0);
		$tile->clear_location();
	}

	$self->{tile} = $tile;
}

sub remove_tile {
	my ($self) = @_;

	$self->set_tile(undef);
}

sub get_bonus {
	my ($self) = @_;
	
	return $self->{bonus};
}

sub print {
	my ($self) = @_;
	
	print $self->{tile} ? uc($self->{tile}->get()) : '.';
}

1;
