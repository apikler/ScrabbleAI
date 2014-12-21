package GUI::GameInfoFrame::Scoreboard;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Scoreboard");

	$self->{label}->set_text(sprintf("You: %d\nAI: %d",
		$self->{game}->get_player()->get_score(),
		$self->{game}->get_aiplayer()->get_score(),
	));
}

1;
