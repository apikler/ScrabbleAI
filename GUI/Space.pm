package GUI::Space;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Item);

use GUI::Utils;

use Data::Dumper;

my %colors = (
	'3W' => GUI::Utils::get_gdk_color(210, 70, 50),
	'2W' => GUI::Utils::get_gdk_color(220, 150, 150),
	'3L' => GUI::Utils::get_gdk_color(50, 160, 205),
	'2L' => GUI::Utils::get_gdk_color(150, 200, 215),
	''  =>  GUI::Utils::get_gdk_color(195, 190, 175),
);

sub new {
	my ($class, $space, @args) = @_;
	
	my $self = $class->SUPER::new(@args);
	bless($self, $class);
	
	$self->{space} = $space;
	
	return $self;
}

sub fill_color {
	my ($self) = @_;
	
	$self->set(
		fill_color_gdk => $colors{$self->{space}->get_bonus()},
	)
}

1;
