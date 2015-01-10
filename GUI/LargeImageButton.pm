##########################################################################
# GUI::LargeImageButton
# A button that has an image on top and a label beneath that.
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

package GUI::LargeImageButton;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gtk2::Button);

sub new {
	my ($class, $image, $markup) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	my $label = Gtk2::Label->new();
	$label->set_markup($markup);
	$label->set_justify('center');

	my $vbox = Gtk2::VBox->new(1, 0);

	$vbox->pack_start($image, 1, 1, 0);
	$vbox->pack_start($label, 1, 1, 0);

	$self->add($vbox);

	return $self;
}


1;
