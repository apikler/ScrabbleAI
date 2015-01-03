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

	my $hbox = Gtk2::HBox->new(0, 0);
	$self->add($hbox);

	$self->{label} = Gtk2::Label->new();
	$self->{label}->set_justify('left');
	$hbox->pack_start($self->{label}, 0, 0, 4);

	$self->show();
	$self->refresh();

	return $self;
}

1;
