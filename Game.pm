package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;
use Player::AIPlayer;
use Bag;

use GUI::Window;

sub new {
	my ($class) = @_;
	
	my $library = Library->new();
	my $board = Board->new();
	
	my $self = bless({
		board => $board,
		library => $library,
		aiplayer => Player::AIPlayer->new($board, $library),
		bag => Bag->new(),
		window => GUI::Window->new(),
	}, $class);
	
	$self->{window}->launch();
	
	return $self;
}

1;
