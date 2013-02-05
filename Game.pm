package Game;

use strict;
use warnings;

use Data::Dumper;

use Board;
use Library;

sub new {
	my ($class) = @_;
	
	my $board = Board->new();
	$board->print_spaces();
	
	my $self = bless({
		board => $board,
		library => Library->new(),
	}, $class);
	
	print "Started\n";
	$self->{library}->get_legal_words("animalss");
	$self->{library}->get_legal_words("abcdefgh");
	$self->{library}->get_legal_words("ijklmnop");
	print "Done\n";
	
	return $self;
}


1;
