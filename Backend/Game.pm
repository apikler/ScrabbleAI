package Backend::Game;

use strict;
use warnings;

use Data::Dumper;

use Backend::Board;
use Backend::Library;
use Backend::Player::AIPlayer;
use Backend::Bag;

sub new {
	my ($class) = @_;
	
	my $library = Backend::Library->new();
	my $board = Backend::Board->new();
	
	my $self = bless({
		board => $board,
		library => $library,
		aiplayer => Backend::Player::AIPlayer->new($board, $library),
		player => Backend::Player->new($board),
		bag => Backend::Bag->new(),
		turn => 0,
	}, $class);
	
	return $self;
}

sub reset {
	my ($self, $difficulty) = @_;

	$self->{bag}->reset();
	$self->{board}->reset();

	$self->{player}->reset();
	$self->{aiplayer}->reset();
	$self->{aiplayer}->set_difficulty($difficulty);

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

sub get_bag {
	my ($self) = @_;
	return $self->{bag};
}

sub get_aiplayer {
	my ($self) = @_;

	return $self->{aiplayer};
}

sub bag_count {
	my ($self) = @_;
	return $self->{bag}->count();
}

# Does the scoring at the end of the game, where:
#	- Each player loses points equal to the sum of their unplayed letters
#	- Each player who played all their tiles receives points equal to the sum
#		of all the other players' unplayed letters.
sub game_end_scoring {
	my ($self) = @_;

	my @players = ($self->{player}, $self->{aiplayer});

	# Subtract each player's unplayed letter total from their score.
	my $unplayed_total = 0;
	for my $player (@players) {
		my $unplayed = $player->get_rack()->value();
		$unplayed_total += $unplayed;
		$player->increment_score(-$unplayed);
	}

	# For each player that played all their letters, increment their score
	# by the sum of the value of the unplayed letters.
	for my $player (@players) {
		if ($player->get_rack()->size() == 0) {
			$player->increment_score($unplayed_total);
		}
	}
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
