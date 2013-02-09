package Player;

use strict;
use warnings;

use Letter;

sub new {
	my ($class, $board) = @_;
	
	my $self = bless({
		board => $board,
		rack => [],
	}, $class);
	
	return $self;
}

# Fills the player's rack up to 7 letters. If there are less than that many
# letters remaining in the bag, all of them are drawn.
sub draw_hand {
	my ($self, $bag) = @_;
	
	my $handsize = scalar(@{$self->{rack}});
	# The number of letters to draw to get to a rack of 7:
	my $todraw = 7 - $handsize;
	# If there aren't enough letters in the bag:
	my $bagcount = $bag->count();
	$todraw = $bagcount if $bagcount < $todraw;
	
	for my $i (1..$todraw) {
		push (@{$self->{rack}}, $bag->draw());
	}
}

1;