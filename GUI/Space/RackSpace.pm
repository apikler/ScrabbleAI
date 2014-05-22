package GUI::Space::RackSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::Space);

use GUI::Utils;

sub new {
	my ($class, $root, $rack) = @_;

	my $self = $class->SUPER::new(
		$root,
		'Gnome2::Canvas::Group',
	);
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		width_pixels => 0,
		fill_color_gdk => GUI::Utils::rack_color,
	);

	$self->{rack} = $rack;

	return $self;
}

1;
