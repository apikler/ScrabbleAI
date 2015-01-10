##########################################################################
# ScrabbleAI::GUI::SettingsManager
# Utility class to save various GUI settings to the disk and reload them
# the next time the program is started. Used for saving and loading
# window position, window size, and difficulty.
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

package ScrabbleAI::GUI::SettingsManager;

use strict;
use warnings;

use ScrabbleAI::Backend::Utils;

use Data::Dumper;
use Storable;

# File where the settings are saved
use constant FILENAME => ScrabbleAI::Backend::Utils::abs_path('GUI/settings');

# Creates a new instance of this class; if the settings file exists on disk,
# loads the settings (key => value pairs as a hashref) from that file.
sub new {
	my ($class) = @_;

	my $self = bless({
		settings => {},
	}, $class);

	# If the settings file exists, load its contents.
	if (-e FILENAME) {
		$self->{settings} = retrieve(FILENAME);
	}

	return $self;
}

# Returns the value of the setting with key $key (a string). If this key has not
# been set, returns $default.
sub get {
	my ($self, $key, $default) = @_;

	if (defined $self->{settings}{$key}) {
		return $self->{settings}{$key};
	}
	else {
		if (defined $default) {
			return $default;
		}
		else {
			return undef;
		}
	}
}

# Sets the settings according to $new_settings, which is a hashref of
# {key => value} pairs.
# NOTE: This does not delete existing settings that are not in $new_settings.
sub set {
	my ($self, $new_settings) = @_;

	while (my ($key, $value) = each %$new_settings) {
		$self->{settings}{$key} = $value;
	}
}

# Clears all the settings
sub clear {
	my ($self) = @_;

	$self->{settings} = {};
}

# Saves the key => value pairs to disk.
sub save {
	my ($self) = @_;

	store($self->{settings}, FILENAME);
}

1;
