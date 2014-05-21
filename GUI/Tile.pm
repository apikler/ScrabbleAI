package GUI::Tile;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

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

	return $self;
}

sub draw {
	my ($self, $side) = @_;

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);

	$self->{rect}->show();
	$self->show();
}

1;
