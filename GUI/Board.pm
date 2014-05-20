package GUI::Board;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use GUI::Space;

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
		
		$self->{spaces}->{"$i,$j"} = GUI::Space->new(
			$board->get_space($i, $j),
			$self, 
			'Gnome2::Canvas::Rect',
			x1 => 0, y1 => 0,
			x2 => 0, y2 => 0,
			outline_color => 'black',
			width_pixels => 2,
		);
		$self->{spaces}->{"$i,$j"}->hide();
	});
	
	return $self;
}

sub draw {
	my ($self, $side) = @_;
	
	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;
		
		$self->{spaces}->{"$i,$j"}->set(
			x1 => $i*$side, y1 => $j*$side,
			x2 => $i*$side + $side, y2 => $j*$side + $side,
		);
		$self->{spaces}->{"$i,$j"}->show();
		$self->{spaces}->{"$i,$j"}->fill_color();
	});
}

1;
