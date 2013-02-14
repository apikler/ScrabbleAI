package Player;

use strict;
use warnings;

use Data::Dumper;

use Tile;
use Rack;

sub new {
	my ($class, $board) = @_;
	
	my $self = bless({
		board => $board,
		rack => Rack->new(),
	}, $class);
	
	return $self;
}

# Fills the player's rack up to 7 tiles. If there are less than that many
# tiles remaining in the bag, all of them are drawn.
sub draw_hand {
	my ($self, $bag) = @_;
	
	my $handsize = $self->{rack}->size();
	# The number of tiles to draw to get to a rack of 7:
	my $todraw = 7 - $handsize;
	# If there aren't enough tiles in the bag:
	my $bagcount = $bag->count();
	$todraw = $bagcount if $bagcount < $todraw;
	
	for my $i (1..$todraw) {
		$self->{rack}->add_tile($bag->draw());
	}
}

1;
