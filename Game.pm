package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;
use Player::AIPlayer;
use Bag;

sub new {
	my ($class) = @_;
	
	my $library = Library->new();
	my $board = Board->new();
	
	my $self = bless({
		board => $board,
		library => $library,
		aiplayer => Player::AIPlayer->new($board, $library),
		bag => Bag->new(),
	}, $class);
	
	for my $i (0..10) {
		$self->{aiplayer}{rack}{tiles} = [];
		$self->{aiplayer}->draw_hand($self->{bag});
		my $move = $self->{aiplayer}->get_move();
		$board->make_move($move);
		$self->{board}->print_spaces();
	}
	
	return $self;
}

1;
