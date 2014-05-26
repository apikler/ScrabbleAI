package GUI::Rack;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Group);

use Gnome2::Canvas;

use GUI::Utils;
use GUI::Space::RackSpace;

use Data::Dumper;

sub new {
	my ($class, $root, $rack, $coords) = @_;

	my $self = $class->SUPER::new($root, 'Gnome2::Canvas::Group');
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		outline_color => 'black',
		width_pixels => 2,
		fill_color_gdk => GUI::Utils::rack_color(),
	);

	my @spaces;
	foreach my $i (0..7) {
		my $gui_space = GUI::Space::RackSpace->new($self, $rack);
		push(@spaces, $gui_space);
	}

	$self->{spaces} = \@spaces;
	$self->{rack} = $rack;

	$self->refresh();

	return $self;
}

sub refresh {
	my ($self) = @_;

	my $tiles = $self->{rack}->get_tiles();
	foreach my $tile (@$tiles) {
		unless ($self->_tile_drawn($tile)) {
			$self->get_first_empty_space()->create_tile($tile);
		}
	}
}

sub _tile_drawn {
	my ($self, $tile) = @_;

	foreach my $space (@{$self->{spaces}}) {
		if ($space->has_tile()) {
			return 1 if $space->get_tile()->get_tile() == $tile;
		}
	}

	return 0;
}

sub get_first_empty_space {
	my ($self) = @_;

	foreach my $space (@{$self->{spaces}}) {
		return $space unless $space->has_tile();
	}

	return undef;
}

sub commit {
	my ($self) = @_;

	my @tiles;
	foreach my $space (@{$self->{spaces}}) {
		if ($space->has_tile()) {
			push(@tiles, $space->get_tile()->get_tile());
		}
	}

	$self->{rack}->set_tiles(\@tiles);
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

	$self->set(x => $x1, y=>$y);
	$self->{rect}->set(x1 => 0, y1 => 0, x2 => $width, y2 => $height);

	# Re-position the 8 spaces within the rack
	foreach my $i (0..$#{$self->{spaces}}) {
		$self->{spaces}[$i]->draw($padding + $i*$side, $padding, $side);
	}

	$self->{rect}->show();
	$self->show();
}

1;

