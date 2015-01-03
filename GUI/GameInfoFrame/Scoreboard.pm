package GUI::GameInfoFrame::Scoreboard;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::GameInfoFrame);

sub refresh {
	my ($self) = @_;

	$self->set_label("Scoreboard");

	my $aiplayer = $self->{game}->get_aiplayer();
	$self->{left_label}->set_markup(sprintf("Level %d AI:\nYou:", $aiplayer->get_difficulty()));

	$self->{right_label}->set_markup(sprintf("<b>%d</b>\n<b>%d</b>",
		$aiplayer->get_score(),
		$self->{game}->get_player()->get_score(),
	));
}

1;
