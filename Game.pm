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
	
	$self->{aiplayer}->draw_hand($self->{bag});
	# $self->{aiplayer}->{rack}->set("efitp**");
	
	$self->{board}->place_word('test', 14, 5, 1);
	# $self->{board}->print_bonuses();
	$self->{board}->print_spaces();
	
	my $move = $self->{aiplayer}->get_move();
	$board->make_move($move);
	$self->{board}->print_spaces();
	
	return $self;
}

1;
