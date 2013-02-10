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
	
	$self->{board}->place_word('hello', 6, 10);
	$self->{board}->place_word('world', 9, 7, 1);
	$self->{board}->print_spaces();
	$self->{board}->transpose();
	print "\n";
	$self->{board}->print_spaces();
	
	$self->{aiplayer}->get_move();
	
	return $self;
}

1;
