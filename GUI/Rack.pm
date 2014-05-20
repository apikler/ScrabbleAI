package GUI::Rack;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Item);

use GUI::Utils;

use Data::Dumper;

sub new {
	my ($class, $root, $rack, $coords) = @_;

	my $self = $class->SUPER::new(
		$root,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => GUI::Utils::get_gdk_color(0, 150, 0),
	);
	bless($self, $class);

	$self->{rack} = $rack;

	return $self;
}

# Draws the rack in the given location, centered below the board.
# x: x-coordinate of the left side of the board
# y: y-coordinate of what will be the top of the rack
# side: side length of one tile
# padding: padding in pixels around the side of the rack
sub draw {
	my ($self, $x, $y, $side, $padding) = @_;

	my $board_side = 15*$side;
	my $width = 8*$side + 2*$padding;
	my $height = $side + 2*$padding;

	my $x1 = $x + ($board_side - $width)/2;
	my @coords = (
		x1 => $x1, y1 => $y,
		x2 => $x1 + $width, y2 => $y + $height,
	);
	$self->set(@coords);

	$self->show();
}

1;

