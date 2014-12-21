package GUI::Tile;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use Gnome2::Canvas;

use GUI::Utils;

sub new {
	my ($class, $root, $tile) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 1,
		fill_color_gdk => GUI::Utils::get_gdk_color(0xFF, 0xCC, 0x66),
	);

	$self->{tile} = $tile;

	$self->refresh_text();

	return $self;
}

sub get_tile {
	my ($self) = @_;

	return $self->{tile};
}

# Returns 1 if the tile has been on the board since the beginning of of the turn,
# 0 otherwise.
sub is_committed {
	my ($self) = @_;

	return $self->{tile}->is_on_board();
}

sub refresh_text {
	my ($self) = @_;

	my $letter = $self->{tile}->get() eq '*' ? '' : uc($self->{tile}->get());
	my $value = $letter eq '' ? '' : $self->{tile}->get_value();

	if ($self->{letter}) {
		$self->{letter}->destroy();
	}
	if ($self->{value}) {
		$self->{value}->destroy();
	}

	$self->{letter} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Text',
		text => $letter,
		family => 'Sans',
		anchor => 'center',
		weight => 500,
	);

	unless ($self->{tile}->is_blank()) {
		$self->{value} = Gnome2::Canvas::Item->new(
			$self,
			'Gnome2::Canvas::Text',
			text => $value,
			family => 'Sans',
			anchor => 'se',
		);
	}
}

sub draw {
	my ($self, $side) = @_;

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);

	# Arbitrary scaling factor for text, based on side length
	my $scale = $side / 27;

	if ($self->{letter}) {
		$self->{letter}->set(
			x => $side/2, y => $side/2,
			'size-points' => 15*$scale,
		);

		$self->{letter}->show();
	}

	if ($self->{value}) {
		$self->{value}->set(
			x => $side, y => $side,
			'size-points' => 6*$scale,
		);

		$self->{letter}->show();
	}

	$self->{rect}->show();
	$self->show();
}

1;
