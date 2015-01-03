package GUI::Space::BoardSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::Space);

use Gnome2::Canvas;

use GUI::Utils;

sub new {
	my ($class, $root, $space) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => GUI::Utils::get_space_color($space->get_bonus()),
	);

	$self->{space} = $space;

	return $self;
}

sub set_tile {
	my ($self, $gui_tile) = @_;

	if (!$self->{gui_tile} && !$self->{space}->get_tile()) {
		$self->{gui_tile} = $gui_tile;
	}
}

# If this space has a tile, that tile is removed.
sub remove_tile {
	my ($self) = @_;

	$self->SUPER::remove_tile();
}

# If there's a tile on this space, it is placed onto the Board (the
# back-end Board, not the GUI::Board)
sub commit {
	my ($self) = @_;

	if ($self->{gui_tile}) {
		$self->{space}->set_tile($self->{gui_tile}->get_tile());
	}
}

# Returns the (i, j) board coordinates of this space.
sub get_coords {
	my ($self) = @_;

	return $self->{space}->get_coords();
}

sub draw {
	my ($self, $x, $y, $side) = @_;

	$self->SUPER::draw($x, $y, $side);
}

1;
