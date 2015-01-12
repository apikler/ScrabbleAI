##########################################################################
# ScrabbleAI::GUI::Space::RackSpace
# Canvas element that inherits from ScrabbleAI::GUI::Space and represents a space
# in the user's rack
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

package ScrabbleAI::GUI::Space::RackSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(ScrabbleAI::GUI::Space);

use ScrabbleAI::GUI::Utils;

use Data::Dumper;

sub new {
	my ($class, $root, $rack) = @_;

	my $self = $class->SUPER::new(
		$root,
		'Gnome2::Canvas::Group',
	);
	bless($self, $class);

	$self->{rect} = Gnome2::Canvas::Item->new(
		$self,
		'Gnome2::Canvas::Rect',
		width_pixels => 0,
		fill_color_gdk => ScrabbleAI::GUI::Utils::rack_color,
	);

	$self->{rack} = $rack;

	return $self;
}

1;
