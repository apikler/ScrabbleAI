package GUI::Window;

use strict;
use warnings;

use Gtk2 '-init';

sub new {
	my ($class, $game) = @_;
	
	my $self = bless({
		game => $game,
	}, $class);
	
	return $self;
}

sub launch {
	my ($self) = @_;
	
	my $window = Gtk2::Window->new();
	$window->set_title('Scrabble');
	$window->set_default_size(400, 400);
	$window->signal_connect(destroy => sub { Gtk2->main_quit(); });
	$self->{window} = $window;
	
	my $vbox = Gtk2::VBox->new(0, 6);
	$window->add($vbox);
	$self->{vbox} = $vbox;

	$self->draw_menu_bar();

	$window->show_all();
	Gtk2->main();
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
