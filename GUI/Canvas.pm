package GUI::Canvas;

use strict;
use warnings;

use Gtk2 '-init';

use base qw(Gnome2::Canvas);

use Data::Dumper;

sub new {
	my ($class) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->set_center_scroll_region(0);
	
	my $white = Gtk2::Gdk::Color->new(0xFFFF, 0xFFFF, 0xFFFF);
	$self->modify_bg('normal', $white);
	
	my $root = $self->root();
	$self->{root} = $root;
	
	Gnome2::Canvas::Item->new(
		$root,
		'Gnome2::Canvas::Text',
		x => 20,
		y => 15,
		fill_color => 'black',
		font => 'Sans 14',
		anchor => 'GTK_ANCHOR_NW',
		text => 'Hello world!'
	);
	
	my $box = Gnome2::Canvas::Item->new($root, 'Gnome2::Canvas::Rect',
		x1 => 10, y1 => 10,
		x2 => 150, y2 => 135,
		fill_color => 'red',
		outline_color => 'black',
	);
	$box->lower_to_bottom();
	
	$root->signal_connect(event => sub {
		my ($item, $event) = @_;
		warn "event: " . Dumper($event);
		my $req = $self->allocation();
		warn $req->width() . " " . $req->height();
	});
	
	return $self;
}



1;
