package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;
use Player::AIPlayer;
use Bag;

sub new {
	my ($class) = @_;
	
	my $self = bless({
		board => Board->new(),
		library => Library->new(),
		aiplayer => Player::AIPlayer->new(),
		bag => Bag->new(),
	}, $class);
	
	$self->{aiplayer}->draw_hand($self->{bag});
	
	$self->{board}->place_word('hello', 6, 10);
	$self->{board}->place_word('world', 9, 7, 1);
	$self->{board}->print_spaces();
	$self->{board}->transpose();
	print "\n";
	$self->{board}->print_spaces();
	
	return $self;
}

1;
