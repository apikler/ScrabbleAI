package GUI::Board;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use GUI::Space::BoardSpace;

use Data::Dumper;

sub new {
	my ($class, $board, @args) = @_;
	
	my $self = $class->SUPER::new(@args);
	bless($self, $class);
	
	$self->{board} = $board;
	
	# Initialize the spaces, but don't display them
	$self->{spaces} = {};
	$board->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$self->{spaces}{"$i,$j"} = GUI::Space::BoardSpace->new($self, $space);
	});
	
	return $self;
}

sub foreach_space {
	my ($self, $sub) = @_;

	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;

		&$sub($self->get_space($i, $j), $i, $j);
	});
}

sub get_space {
	my ($self, $i, $j) = @_;

	return $self->{spaces}{"$i,$j"};
}

# Adds the current move to the board.
sub commit_spaces {
	my ($self) = @_;

	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;

		$space->commit();
	});
}

# Takes a Move and creates the necessary tiles on the board.
sub move_to_board {
	my ($self, $move) = @_;

	my $move_tiles = $move->get_tiles();
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;

		my $move_tile = $move_tiles->{"$i,$j"};
		if (!$space->has_tile() && $move_tile) {
			$space->create_tile($move_tile);
		}
	});
}

sub draw {
	my ($self, $side) = @_;
	
	$self->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$space->draw($i*$side, $j*$side, $side);
	});
}

1;
