package GUI::Window;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;
use Glib;

use base qw(Gtk2::Window);

use Game;
use GUI::Canvas;
use GUI::Scoreboard;

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
	$turn_button->signal_connect(clicked => \&_make_move_callback, $self->{canvas});

	my $scoreboard = GUI::Scoreboard->new($self->{game});
	$vbox_widgets->pack_start($scoreboard, 0, 0, 0);
	$self->{scoreboard} = $scoreboard;

	my $statusbar = Gtk2::Statusbar->new();
	$statusbar->set_has_resize_grip(1);
	$vbox_main->pack_end($statusbar, 0, 1, 0);
	$statusbar->show();
	$self->{statusbar} = $statusbar;

	$self->{make_ai_move} = 0;
	Glib::Timeout->add(
		1000,
		\&_ai_timer_callback,
		$self,
	);

	$self->signal_connect(key_press_event => \&_handle_key, $self->{canvas});

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

# Sets the given text as the status in the statusbar at the bottom of the window.
sub set_status {
	my ($self, $text) = @_;

	my $contextid = $self->{statusbar}->get_context_id('game status');
	$self->{statusbar}->push($contextid, $text);
}

sub make_ai_move {
	my ($self) = @_;

	$self->{make_ai_move} = 1;
}

sub refresh_scoreboard {
	my ($self) = @_;

	$self->{scoreboard}->refresh();
}

sub _make_move_callback {
	my ($button, $canvas) = @_;

	$canvas->make_move();
}

sub _ai_timer_callback {
	my ($self) = @_;

	if ($self->{make_ai_move}) {
		$self->{make_ai_move} = 0;

		my $aimove = $self->{game}->get_ai_move();
		my @words = @{$aimove->get_words()};

		if (@words) {
			$self->set_status(sprintf('AI has played "%s" for %d points.', $words[0], $aimove->evaluate()));

			$self->{canvas}{board}->move_to_board($aimove);
			$self->{canvas}{board}->commit_spaces();

			$self->refresh_scoreboard();
		}
		else {
			$self->set_status("AI was unable to make a move!");
		}

		$self->{canvas}->next_turn();
	}

	return 1;
}

sub _handle_key {
	my ($widget, $event, $canvas) = @_;

	# If we're changing the letter on a blank tile, make sure the key is between A and Z.
	my $keyval = $event->keyval();
	my $tile = $canvas->{selected_blank_tile};
	if ($tile && (($keyval >= 97 && $keyval <= 122) || ($keyval >= 65 && $keyval <= 90))) {
		my $letter = lc(chr($keyval));
		$tile->get_tile()->set_blank_letter($letter);
		$canvas->{window}->set_status(sprintf("You have set the blank tile to %s.", uc($letter)));
		$tile->refresh_text();
		delete $canvas->{selected_blank_tile};
	}
}
1;
