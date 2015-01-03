package GUI::LargeImageButton;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gtk2::Button);

sub new {
	my ($class, $image, $markup) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	my $label = Gtk2::Label->new();
	$label->set_markup($markup);
	$label->set_justify('center');

	my $vbox = Gtk2::VBox->new(1, 0);

	$vbox->pack_start($image, 1, 1, 0);
	$vbox->pack_start($label, 1, 1, 0);

	$self->add($vbox);

	return $self;
}


1;
