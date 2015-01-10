##########################################################################
# ScrabbleAI::GUI::KeyItem
# One of the four rows in the ScrabbleAI::GUI::Key. For example:
#	[pink square] 2x Word Bonus
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

package ScrabbleAI::GUI::KeyItem;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;

use ScrabbleAI::GUI::Utils;

use base qw(Gtk2::HBox);

sub new {
	my ($class, $color, $label) = @_;

	my $self = $class->SUPER::new(0, 0);
	bless($self, $class);

	my $canvas = Gnome2::Canvas->new();
	$canvas->modify_bg('normal', $color);

	$self->pack_start($canvas, 0, 0, 4);
	$canvas->set_size_request(20, 20);

	$self->pack_start(Gtk2::Label->new($label), 0, 0, 0);

	return $self;
}



1;
