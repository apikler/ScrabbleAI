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
		player => Player->new($board),
		bag => Bag->new(),
	}, $class);
	
	return $self;
}

sub start {
	my ($self) = @_;

	$self->{player}->draw_hand($self->{bag});
}

sub get_board {
	my ($self) = @_;
	return $self->{board};
}

sub get_player {
	my ($self) = @_;

	return $self->{player};
}

1;
