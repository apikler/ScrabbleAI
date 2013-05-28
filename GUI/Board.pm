package GUI::Board;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas::Item);

use Data::Dumper;

sub new {
	my ($class, $board) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->{board} = $board;
}

1;
