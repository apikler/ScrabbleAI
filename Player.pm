package Player;

use strict;
use warnings;

sub new {
	my ($class, $board) = @_;
	
	my $self = bless({
		board => $board,
	}, $class);
	
	return $self;
}


1;
