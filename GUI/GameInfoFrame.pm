package GUI::GameInfoFrame;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gtk2::Frame);

sub new {
	my ($class, $game) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	$self->{game} = $game;

	$self->{label} = Gtk2::Label->new();
	$self->{label}->set_justify('left');
	$self->add($self->{label});

	$self->show();
	$self->refresh();

	return $self;
}

1;
