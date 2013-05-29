package GUI::Canvas;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas);

use GUI::Board;

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

sub draw {
	my $self = shift;
	
	my $allocation = $self->allocation();
	my ($w, $h) = ($allocation->width(), $allocation->height());
	
	# Margin to leave on top/bottom, in pixels:
	my $margin = 30;
	# Margin to leave on the sides:
	my $sidemargin = 30;
	
	# Center the board and figure out its dimensions
	my $hspace = $w - 2*$sidemargin;
	my $vspace = $h - 2*$margin;
	my ($x, $y, $side);
	if ($hspace >= $vspace) {
		$side = $vspace;
		$y = $margin;
		$x = $sidemargin + ($hspace - $side)/2;
	}
	else {
		$side = $hspace;
		$x = $sidemargin;
		$y = $margin + ($vspace - $side)/2;
	}
	my %dimensions = (
		x => $x, y => $y,
	);
	
	if ($self->{board}) {
		$self->{board}->set(%dimensions);
	}
	else {
		my $board = GUI::Board->new(
			$self->{game}->get_board(), 
			$self->{root},
			'Gnome2::Canvas::Group',
			%dimensions,
		);
		$self->{board} = $board;
	}
	
	$self->{board}->draw($side);
	
	# The expose_event from the drawing we just did shouldn't call this function again, or 
	# we'll get an infinite loop.
	$self->{prevent_expose_event} = 1;
}


1;
