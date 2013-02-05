package Space;

use strict;
use warnings;

sub new {
	my ($class, $bonus) = @_;
	
	my $self = bless({
		bonus => $bonus,
		letter => '',
	}, $class);
	
	return $self;
}

sub get_letter {
	my $self = @_;
	
	return $self->{letter};
}

sub set_letter {
	my ($self, $letter) = @_;
	
	$self->{letter} = $letter;
}

sub get_bonus {
	my ($self) = @_;
	
	return $self->{bonus};
}

1;
