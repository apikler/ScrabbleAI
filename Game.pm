package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;
use Player::AIPlayer;
use Bag;

sub new {
	my ($class, $difficulty) = @_;
	
	my $library = Library->new();
	my $board = Board->new();
	
	my $self = bless({
		board => $board,
		library => $library,
		aiplayer => Player::AIPlayer->new($board, $library, $difficulty),
		player => Player->new($board),
		bag => Bag->new(),
		turn => 0,
	}, $class);
	
	return $self;
}

sub start {
	my ($self) = @_;

	$self->fill_racks();
}

sub next_turn {
	my ($self) = @_;

	$self->fill_racks();

	$self->{turn}++;
}

sub fill_racks {
	my ($self) = @_;

	$self->{player}->draw_hand($self->{bag});
	$self->{aiplayer}->draw_hand($self->{bag});
}

sub get_board {
	my ($self) = @_;
	return $self->{board};
}

sub get_player {
	my ($self) = @_;

	return $self->{player};
}

sub get_aiplayer {
	my ($self) = @_;

	return $self->{aiplayer};
}

# Returns the AI player's move, removing the relevant tiles from
# the AI's rack, and incrementing the AI's score.
sub get_ai_move {
	my ($self) = @_;

	my $move = $self->get_aiplayer()->get_move();
	if ($move) {
		$self->{aiplayer}->increment_score($move->evaluate());

		my @move_tiles = values %{$move->get_tiles()};
		foreach my $tile (@move_tiles) {
			$self->get_aiplayer()->get_rack()->remove($tile->get(), 1);
		}
	}

	return $move;
}

1;
