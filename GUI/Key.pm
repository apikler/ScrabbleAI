package GUI::Key;

use strict;
use warnings;

use Gtk2 '-init';

use GUI::KeyItem;
use GUI::Utils;

use base qw(Gtk2::Frame);

sub new {
	my ($class) = @_;

	my $self = $class->SUPER::new();
	bless($self, $class);

	$self->set_label('Key');

	my $vbox = Gtk2::VBox->new();
	$self->add($vbox);

	my @keyitems = (
		GUI::KeyItem->new(GUI::Utils::get_space_color('2L'), '2x letter score'),
		GUI::KeyItem->new(GUI::Utils::get_space_color('3L'), '3x letter score'),
		GUI::KeyItem->new(GUI::Utils::get_space_color('2W'), '2x word score'),
		GUI::KeyItem->new(GUI::Utils::get_space_color('3W'), '3x word score'),
	);

	for my $keyitem (@keyitems) {
		$vbox->pack_start($keyitem, 0, 0, 0);
	}

	return $self;
}

1;
