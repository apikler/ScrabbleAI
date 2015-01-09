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

sub abs_path {
	my ($path) = @_;

	return $FindBin::Bin . "/$path";
}

1;
