package GUI::Space::BoardSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::Space);

use Gnome2::Canvas;

use GUI::Utils;

my %colors = (
	'3W' => GUI::Utils::get_gdk_color(210, 70, 50),
	'2W' => GUI::Utils::get_gdk_color(220, 150, 150),
	'3L' => GUI::Utils::get_gdk_color(50, 160, 205),
	'2L' => GUI::Utils::get_gdk_color(150, 200, 215),
	''  =>  GUI::Utils::get_gdk_color(195, 190, 175),
);

sub new {
	my ($class, $root, $space) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => $colors{$space->get_bonus()}
	);

	$self->{space} = $space;

	return $self;
}

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->{rect}->set(
		x1 => 0, y1 => 0,
		x2 => $side, y2 => $side,
	);
	$self->{rect}->show();

	$self->SUPER::draw($x, $y, $side);
}

1;
