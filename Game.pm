package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;

sub new {
	my ($class) = @_;
	
	my $board = Board->new();
	$board->print_spaces();
	
	my $self = bless({
		board => $board,
		library => Library->new(),
	}, $class);
	
	return $self;
}


1;
