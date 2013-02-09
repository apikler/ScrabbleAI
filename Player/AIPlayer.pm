package Player::AIPlayer;
use base qw(Player);

use strict;
use warnings;

sub new {
	my ($class, $board) = @_;
	
	my $self = Player->new($board);
	
	bless($self, $class);
	
	return $self;
}


1;
