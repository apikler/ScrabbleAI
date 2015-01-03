package GUI::GameInfoFrame::TileCount;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Tile Counts");

	my $aiplayer = $self->{game}->get_aiplayer();
	$self->{left_label}->set_markup(sprintf("Bag:\nLevel %d AI:\nYou:", $aiplayer->get_difficulty()));

	$self->{right_label}->set_markup(sprintf("<b>%d</b> tiles\n<b>%d</b> tiles\n<b>%d</b> tiles",
		$self->{game}->bag_count(),
		$aiplayer->get_rack()->size(),
		$self->{game}->get_player()->get_rack()->size(),
	));
}

1;

