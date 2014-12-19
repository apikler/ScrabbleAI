package GUI::Scoreboard;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gtk2::Frame);

sub new {
	my ($class, $game) = @_;

	my $self = $class->SUPER::new("Scoreboard");
	bless($self, $class);

	$self->{game} = $game;

	$self->{label} = Gtk2::Label->new();
	$self->{label}->set_justify('left');
	$self->add($self->{label});

	$self->show();
	$self->refresh();

	return $self;
}

sub refresh {
	my ($self) = @_;

	$self->{label}->set_text(sprintf("You: %d\nAI: %d",
		$self->{game}->get_player()->get_score(),
		$self->{game}->get_aiplayer()->get_score(),
	));
}

1;
