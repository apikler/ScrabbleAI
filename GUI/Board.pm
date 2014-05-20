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
		
		$self->{spaces}->{"$i,$j"} = GUI::Space::BoardSpace->new(
			$self,
			$board->get_space($i, $j),
		);
	});
	
	return $self;
}

sub draw {
	my ($self, $side) = @_;
	
	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$self->{spaces}->{"$i,$j"}->draw($i*$side, $j*$side, $side);
	});
}

1;
