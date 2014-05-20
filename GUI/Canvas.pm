package GUI::Canvas;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas);

use GUI::Board;
use GUI::Rack;

use Data::Dumper;

sub new {
	my ($class, $window, $game) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->{game} = $game;
	$self->{window} = $window;
	
	$self->set_center_scroll_region(0);
	
	my $white = Gtk2::Gdk::Color->new(0xFFFF, 0xFFFF, 0xFFFF);
	$self->modify_bg('normal', $white);
	
	my $root = $self->root();
	$self->{root} = $root;
	
	#Gnome2::Canvas::Item->new(
		#$root,
		#'Gnome2::Canvas::Text',
		#x => 20,
		#y => 15,
		#fill_color => 'black',
		#font => 'Sans 14',
		#anchor => 'GTK_ANCHOR_NW',
		#text => 'Hello world!'
	#);
	
	# Event that handles drawing the board whenever the canvas is resized
	$self->signal_connect(expose_event => sub {
		if ($self->{prevent_expose_event}) {
			$self->{prevent_expose_event} = 0;
			return 0;
		}

		$self->draw();
		return 0;
	});
	
	return $self;
}

sub get_dimensions {
	my ($self) = @_;

	my $allocation = $self->allocation();
	return ($allocation->width(), $allocation->height());
}

sub draw {
	my ($self) = @_;

	my ($w, $h) = $self->get_dimensions();

	# Margin to leave at the sides of the canvas, in pixels
	my $margin = 10;

	# Space between various elements, in pixels
	my $space = 10;

	# Padding on some elements, like the rack
	my $padding = 5;

	# Tile side length vertically
	my $side_vert = ($h - (2*$margin + 2*$padding + $space)) / 16;	# There has to be room for 16 tiles vertically (board + rack)

	# Tile side length horizontally
	my $side_horiz = ($w - 2*$margin) / 15;	# There has to be room for 15 tiles horizontally (just the board)

	# We want the side length to be whichever of the above measurements is less, so that
	# the board doesn't spill off screen in the other dimension.
	my $side = $side_horiz <= $side_vert ? $side_horiz : $side_vert;

	# The dimensions of the play area. The rest of the area outside of this is just whitespace, depending
	# on the dimensions of the window.
	my $area_w = 15*$side + 2*$margin;
	my $area_h = 16*$side + 2*$margin + 2*$padding + $space;

	# Now we want to figure out $x and $y, the coordinates of the upper left corner of the board, such that
	# the board is centered.
	my ($x, $y);
	if ($side_horiz >= $side_vert) {
		# The window is sized such that there is more whitespace horizontally.
		$y = $margin;
		$x = ($w - $area_w) / 2 + $margin;
	}
	else {
		# There is more whitespace vertically
		$x = $margin;
		$y = ($h - $area_h) / 2 + $margin;
	}

	my %coords = (
		x => $x,
		y => $y,
	);

	if ($self->{board}) {
		$self->{board}->set(%coords);
	}
	else {
		my $board = GUI::Board->new(
			$self->{game}->get_board(),
			$self->{root},
			'Gnome2::Canvas::Group',
			%coords,
		);
		$self->{board} = $board;
	}

	$self->{board}->draw($side);

	# Draw the player's visible rack
	my $rack = $self->{game}->get_player()->get_rack();
	unless ($self->{rack}) {
		$self->{rack} = GUI::Rack->new($self->{root}, $rack);
	}

	$self->{rack}->draw($x, $y + 15*$side + $space, $side, $padding);

	$self->{prevent_expose_event} = 1;
}

1;
