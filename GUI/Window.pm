package GUI::Window;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;

use base qw(Gtk2::Window);

use Game;
use GUI::Canvas;

use Data::Dumper;

sub new {
	my ($class, $game) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->{game} = $game;
	
	$self->set_title('Scrabble');
	$self->set_default_size(500, 500);
	$self->signal_connect(destroy => sub { Gtk2->main_quit(); });
	
	my $vbox = Gtk2::VBox->new(0, 6);
	$self->add($vbox);
	$self->{vbox} = $vbox;

	$self->draw_menu_bar();
	
	$self->{canvas} = GUI::Canvas->new($self, $game);
	$self->{vbox}->pack_start($self->{canvas}, 1, 1, 0);

	#my $a = 0;
	#$self->signal_connect(expose_event => sub {
		#warn "window event! $a";
		#$a++;
	#});

	$self->show_all();
	
	return $self;
}

sub draw_menu_bar {
	my ($self) = @_;
	
	my $menubar = Gtk2::MenuBar->new();
	$self->{menubar} = $menubar;
	
	my $filemenu = Gtk2::Menu->new();
	$filemenu->append(Gtk2::SeparatorMenuItem->new());
	my $quit_item = Gtk2::ImageMenuItem->new_from_stock('gtk-quit', undef);
	$quit_item->signal_connect(activate => sub { Gtk2->main_quit(); });
	$filemenu->append($quit_item);
	
	my $filemenu_item = Gtk2::MenuItem->new('_File');
	$filemenu_item->set_submenu($filemenu);
	$menubar->append($filemenu_item);
	
	my $helpmenu = Gtk2::Menu->new();
	my $about_item = Gtk2::ImageMenuItem->new_from_stock('gtk-about', undef);
	# TODO: popup
	$about_item->signal_connect(activate => sub {} );
	$helpmenu->append($about_item);
	
	my $helpmenu_item = Gtk2::MenuItem->new('_Help');
	$helpmenu_item->set_submenu($helpmenu);
	$menubar->append($helpmenu_item);
	
	$self->{vbox}->pack_start($menubar, 0, 0, 0);
}

1;
