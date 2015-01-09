##########################################################################
# Backend::Utils
# Various utility functions used throughout the program
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

package Backend::Utils;

use strict;
use warnings;

use FindBin;

# Given an arrayref of coordinates '(i,j)' and a position 0 or 1,
# returns an array of only the coordinates of that position.
sub coord_position {
	my ($coords, $position) = @_;

	my @result;
	foreach my $coord (@$coords) {
		$coord =~ /(\d+)\,(\d+)/;
		if ($position == 0) {
			push(@result, $1);
		}
		elsif ($position == 1) {
			push(@result, $2);
		}
	}

	return @result;
}

# Given a coordinate expressed as a string like "2,3" returns the coordinate
# as an arrayref: [2, 3].
sub split_coord {
	my ($string) = @_;

	$string =~ /(\d+)\,(\d+)/;
	return [$1, $2];
}

# Returns 1 if all the elements of the given arrayref are equal, 0 otherwise.
# Uses numeric comparision unless $string == 1.
sub same_elements {
	my ($elements, $string) = @_;

	return 1 if @$elements <= 1;

	foreach my $i (1..$#$elements) {
		my $this = $elements->[$i];
		my $previous = $elements->[$i-1];

		if ($string) {
			return 0 if $this ne $previous;
		}
		else {
			return 0 if $this != $previous;
		}
	}

	return 1;
}

# Given a relative path $path (such as 'Backend/library'), returns the corresponding
# abdolute path.
sub abs_path {
	my ($path) = @_;

	return $FindBin::Bin . "/$path";
}

1;
