package GUI::GameInfoFrame::TileCount;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Tile Counts");

	my $aiplayer = $self->{game}->get_aiplayer();
	$self->{label}->set_markup(sprintf("Bag: <b>%d</b> tiles\nLevel %d AI: <b>%d</b> tiles\nYou: <b>%d</b> tiles",
		$self->{game}->bag_count(),
		$aiplayer->get_difficulty(),
		$aiplayer->get_rack()->size(),
		$self->{game}->get_player()->get_rack()->size(),
	));
}

1;

