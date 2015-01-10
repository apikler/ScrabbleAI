##########################################################################
# ScrabbleAI::GUI::GameInfoFrame
# Widget that displays information about the game state to the user.
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

package ScrabbleAI::GUI::GameInfoFrame;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gtk2::Frame);

sub new {
	my ($class, $game) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	$self->{game} = $game;

	my $hbox = Gtk2::HBox->new(0, 0);
	$self->add($hbox);

	$self->{right_label} = Gtk2::Label->new();
	$self->{right_label}->set_justify('left');
	$self->{left_label} = Gtk2::Label->new();
	$self->{left_label}->set_justify('left');
	$hbox->pack_start($self->{left_label}, 0, 0, 4);
	$hbox->pack_start($self->{right_label}, 0, 0, 4);

	$self->show();
	$self->refresh();

	return $self;
}

1;
