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
	$self->set_default_size(700, 700);
	$self->signal_connect(destroy => sub { Gtk2->main_quit(); });
	
	my $vbox_main = Gtk2::VBox->new(0, 6);
	my $vbox_widgets = Gtk2::VBox->new(0, 6);
	my $hbox = Gtk2::HBox->new(0, 6);

	$self->add($vbox_main);
	$self->draw_menu_bar($vbox_main);

	$vbox_main->pack_start($hbox, 1, 1, 0);
	$self->{canvas} = GUI::Canvas->new($self, $game);
	$hbox->pack_start($self->{canvas}, 1, 1, 0);

	$hbox->pack_start($vbox_widgets, 0, 0, 0);
	my $turn_button = Gtk2::Button->new('Make Move');
	$vbox_widgets->pack_start($turn_button, 0, 0, 0);
	$turn_button->signal_connect(clicked => \&GUI::Canvas::make_move, $self->{canvas});

	$self->show_all();
	
	return $self;
}

sub draw_menu_bar {
	my ($self, $box) = @_;
	
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
	
	$box->pack_start($menubar, 0, 0, 0);
}

1;
