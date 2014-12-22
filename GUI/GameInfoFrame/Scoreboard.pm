package GUI::GameInfoFrame::Scoreboard;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Scoreboard");

	my $aiplayer = $self->{game}->get_aiplayer();
	$self->{label}->set_markup(sprintf("You: <b>%d</b>\nLevel %d AI: <b>%d</b>",
		$self->{game}->get_player()->get_score(),
		$aiplayer->get_difficulty(),
		$aiplayer->get_score(),
	));
}

1;
