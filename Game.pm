package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;
use Player::AIPlayer;

sub new {
	my ($class) = @_;
	
	my $board = Board->new();
	$board->print_spaces();
	
	my $aiplayer = Player::AIPlayer->new();
	
	my $self = bless({
		board => $board,
		library => Library->new(),
		aiplayer => $aiplayer,
	}, $class);
	
	return $self;
}


1;
