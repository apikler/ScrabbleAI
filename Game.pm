package Game;

use strict;
use warnings;

use Board;

sub new {
	my ($class) = @_;
	
	my $board = Board->new();
	
	my $self = bless({
		board => $board,
	}, $class);
	
	return $self;
}


1;
