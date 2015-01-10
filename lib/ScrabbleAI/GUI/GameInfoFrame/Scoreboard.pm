##########################################################################
# ScrabbleAI::GUI::GameInfoFrame::Scoreboard
# Widget that displays the user and AI's scores
#
# Copyright (C) 2015 Andrew Pikler
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

package ScrabbleAI::GUI::GameInfoFrame::Scoreboard;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(ScrabbleAI::GUI::GameInfoFrame);

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
