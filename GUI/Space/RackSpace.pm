package GUI::Space::RackSpace;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(GUI::Space);

sub new {
	my ($class, $root, $rack) = @_;

	my $self = $class->SUPER::new(
		$root,
		'Gnome2::Canvas::Group',
	);
	bless($self, $class);

	$self->{rack} = $rack;

	return $self;
}

1;
