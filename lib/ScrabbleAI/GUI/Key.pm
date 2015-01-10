##########################################################################
# ScrabbleAI::GUI::Key
# Widget that displays the colors of the four types of bonuses to the user
# and corresponding descriptions.
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

package ScrabbleAI::GUI::Key;

use strict;
use warnings;

use Gtk2 '-init';

use ScrabbleAI::GUI::KeyItem;
use ScrabbleAI::GUI::Utils;

use base qw(Gtk2::Frame);

sub new {
	my ($class) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	$self->set_label('Key');

	my $vbox = Gtk2::VBox->new();
	$self->add($vbox);

	my @keyitems = (
		ScrabbleAI::GUI::KeyItem->new(ScrabbleAI::GUI::Utils::get_space_color('2L'), '2x letter score'),
		ScrabbleAI::GUI::KeyItem->new(ScrabbleAI::GUI::Utils::get_space_color('3L'), '3x letter score'),
		ScrabbleAI::GUI::KeyItem->new(ScrabbleAI::GUI::Utils::get_space_color('2W'), '2x word score'),
		ScrabbleAI::GUI::KeyItem->new(ScrabbleAI::GUI::Utils::get_space_color('3W'), '3x word score'),
	);

	for my $keyitem (@keyitems) {
		$vbox->pack_start($keyitem, 0, 0, 0);
	}

	return $self;
}

1;
