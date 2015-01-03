package GUI::KeyItem;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;

use GUI::Utils;

use base qw(Gtk2::HBox);

sub new {
	my ($class, $color, $label) = @_;

	my $self = $class->SUPER::new(0, 0);
	bless($self, $class);

	my $canvas = Gnome2::Canvas->new();
	$canvas->modify_bg('normal', $color);

	$self->pack_start($canvas, 0, 0, 4);
	$canvas->set_size_request(20, 20);

	$self->pack_start(Gtk2::Label->new($label), 0, 0, 0);

	return $self;
}



1;
