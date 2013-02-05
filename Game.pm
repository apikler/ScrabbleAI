package Game;

use strict;
use warnings;

use Board;

sub new {
	my ($class) = @_;
	
	my $board = Board->new();
	$board->print_spaces();
	
	my $self = bless({
		board => $board,
	}, $class);
	
	return $self;
}


1;
