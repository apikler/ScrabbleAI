package GUI::GameInfoFrame::BagCount;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Bag");

	$self->{label}->set_markup(sprintf("<b>%d</b> tiles", $self->{game}->bag_count()));
}

1;

