package GUI::Window;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;
use Glib;

use base qw(Gtk2::Window);

use Game;
use GUI::Canvas;
use GUI::GameInfoFrame::Scoreboard;
use GUI::GameInfoFrame::TileCount;
use GUI::Key;

use Data::Dumper;

sub new {
	my ($class) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->set_title('Scrabble');
	$self->set_default_size(700, 700);
	$self->set_icon_list(Gtk2::Gdk::Pixbuf->new_from_file('./GUI/images/s_tile.png'));
	$self->signal_connect(destroy => sub { Gtk2->main_quit(); });

	# An array of widgets that need to get destroyed when switching between the "game" and "intro"
	# versions of the window.
	$self->{widgets} = [];
	
	my $vbox_main = Gtk2::VBox->new(0, 6);
	$self->{vbox_main} = $vbox_main;

	$self->add($vbox_main);
	$self->draw_menu_bar($vbox_main);

	$self->{make_ai_move} = 0;
	Glib::Timeout->add(
		1000,
		\&_ai_timer_callback,
		$self,
	);

	$self->show_all();

	$self->{difficulty} = 5; # Default difficulty
	$self->draw_version('intro');

	return $self;
}

# Draws the indicated version (screen) of the window. $version must be "game" or "intro".
sub draw_version {
	my ($self, $version) = @_;

	$self->destroy();
	my $vbox_main = $self->{vbox_main};

	if (lc($version) eq 'game') {
		unless ($self->{game}) {
			$self->{game} = Game->new();
		}
		$self->{game}->reset($self->{difficulty});

		my $vbox_widgets = Gtk2::VBox->new(0, 6);
		$vbox_widgets->set_size_request(130);
		my $hbox = Gtk2::HBox->new(0, 6);

		$vbox_main->pack_start($hbox, 1, 1, 0);
		$self->{canvas} = GUI::Canvas->new($self, $self->{game});
		$hbox->pack_start($self->{canvas}, 1, 1, 0);

		my @buttons;
		$hbox->pack_start($vbox_widgets, 0, 0, 0);
		my $turn_button = Gtk2::Button->new("Make\nMove");
		$vbox_widgets->pack_end($turn_button, 1, 1, 0);
		$turn_button->signal_connect(clicked => \&_make_move_callback, $self->{canvas});
		push(@buttons, $turn_button);

		my $scoreboard = GUI::GameInfoFrame::Scoreboard->new($self->{game});
		$vbox_widgets->pack_start($scoreboard, 0, 0, 0);
		$self->{scoreboard} = $scoreboard;

		my $tilecount = GUI::GameInfoFrame::TileCount->new($self->{game});
		$vbox_widgets->pack_start($tilecount, 0, 0, 0);
		$self->{tilecount} = $tilecount;

		my $key = GUI::Key->new();
		$vbox_widgets->pack_start($key, 0, 0, 0);

		my $pass_button = Gtk2::Button->new('Pass Turn');
		$vbox_widgets->pack_start($pass_button, 0, 0, 0);
		$pass_button->signal_connect(clicked => \&_pass_turn_callback, $self);
		push(@buttons, $pass_button);

		my $replace_button = Gtk2::Button->new('Replace Tiles');
		$vbox_widgets->pack_start($replace_button, 0, 0, 0);
		$replace_button->signal_connect(clicked => \&_replace_tiles_callback, $self);
		push(@buttons, $replace_button);
		$self->{replace_button} = $replace_button;

		$vbox_widgets->pack_start(Gtk2::SeparatorMenuItem->new(), 0, 0, 0);

		my $return_button = Gtk2::Button->new("Return Tiles\nto Rack");
		$vbox_widgets->pack_end($return_button, 1, 1, 0);
		$return_button->signal_connect(clicked => \&_return_tiles_callback, $self);
		push(@buttons, $return_button);

		$self->signal_connect(key_press_event => \&_handle_key, $self->{canvas});

		my $statusbar = Gtk2::Statusbar->new();
		$statusbar->set_has_resize_grip(1);
		$vbox_main->pack_end($statusbar, 0, 1, 0);
		$statusbar->show();
		$self->{statusbar} = $statusbar;
		$self->set_status('Please drag tiles to the middle of the board to begin.');

		push(@{$self->{widgets}}, $vbox_widgets, $hbox, $statusbar);

		$self->{passcount} = 0;
		$self->{buttons} = \@buttons;
		$self->set_disabled(0);
	}
	elsif (lc($version) eq 'intro') {
		my $hbox = Gtk2::HBox->new(1, 0);
		$vbox_main->pack_start($hbox, 0, 0, 1);

		my $frame = Gtk2::Frame->new("Difficulty");
		$hbox->pack_start($frame, 1, 1, 0);

		my $vbox_difficulty = Gtk2::VBox->new(0, 0);
		$frame->add($vbox_difficulty);

		my $previous_button;
		for my $difficulty (1..10) {
			my $label;
			if ($difficulty == 10) {
				$label = "10 - Extremely hard";
			}
			elsif ($difficulty == 1) {
				$label = "1 - Easiest";
			}
			else {
				$label = sprintf("%d", $difficulty);
			}

			my $button = Gtk2::RadioButton->new($previous_button, $label);
			$vbox_difficulty->pack_end($button, 1, 0, 0);
			$previous_button = $button;

			if ($difficulty == $self->{difficulty}) {
				$button->set_active(1);
			}

			$button->signal_connect(toggled => \&_difficulty_callback, {
				window => $self,
				difficulty => $difficulty,
			});
		}

		my $button = Gtk2::Button->new('Start Game');
		$hbox->pack_end($button, 1, 1, 0);

		push(@{$self->{widgets}}, $hbox);

		$button->signal_connect(clicked => sub { $self->draw_version('game'); });
	}

	$self->show_all();
}

sub draw_menu_bar {
	my ($self, $box) = @_;
	
	my $menubar = Gtk2::MenuBar->new();
	$self->{menubar} = $menubar;
	
	my $filemenu = Gtk2::Menu->new();

	my $new_game_item = Gtk2::ImageMenuItem->new('_New Game');
	$new_game_item->set_image(Gtk2::Image->new_from_stock('gtk-new', 'menu'));
	$new_game_item->signal_connect(activate => sub { $self->draw_version('intro'); });
	$filemenu->append($new_game_item);

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

# Disables the canvas and the clickable buttons in the window according to $disabled.
sub set_disabled {
	my ($self, $disabled) = @_;

	$self->{canvas}->set_disabled($disabled);
	for my $button (@{$self->{buttons}}) {
		$button->set_sensitive(!$disabled);
	}
}

sub destroy {
	my ($self) = @_;

	for my $widget (@{$self->{widgets}}) {
		$widget->destroy();
	}

	$self->{widgets} = [];
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
	$self->set_disabled(1);
}

# Refreshes the scoreboard and the bag tile count displays.
sub refresh_gameinfo {
	my ($self) = @_;

	$self->{scoreboard}->refresh();
	$self->{tilecount}->refresh();
}

# Displays the final score to the player and informs them the game is over.
sub end_game {
	my ($self) = @_;

	$self->set_disabled(1);

	$self->{game}->game_end_scoring();
	$self->refresh_gameinfo();

	my $aiscore = $self->{game}->get_aiplayer()->get_score();
	my $score = $self->{game}->get_player()->get_score();
	my $difficulty = $self->{game}->get_aiplayer()->get_difficulty();

	my $message;
	if ($aiscore == $score) {
		$message = "Game over. You have tied the Level $difficulty AI.";
	}
	elsif ($aiscore > $score) {
		$message = "Game over. Sorry, but the Level $difficulty AI won. Better luck next time!";
	}
	else {
		$message = "Congratulations! You have beaten the Level $difficulty AI.";
	}

	my $dialog = Gtk2::MessageDialog->new(
		$self,
		'destroy-with-parent',
		'info',
		'ok',
		$message,
	);
	$dialog->run();
	$dialog->destroy();

	$self->set_status($message);
}

sub _make_move_callback {
	my ($button, $canvas) = @_;

	$canvas->make_move();
}

sub _return_tiles_callback {
	my ($button, $window) = @_;

	$window->{canvas}->return_tiles_to_rack();
}

sub _replace_tiles_callback {
	my ($button, $window) = @_;

	my $bag_count = $window->{game}->bag_count();
	if ($bag_count == 0) {
		$window->set_status("Sorry, but you can't replace tiles when the bag is empty.");
		return;
	}

	# Disable all the buttons except the Replace Tiles button and the Canvas.
	$window->set_disabled(1);
	$window->{replace_button}->set_sensitive(1);
	$window->{canvas}->set_disabled(0);

	if ($bag_count < 7) {
		$window->set_status("Click on at most $bag_count tile(s) you want to replace, then click Replace Tiles again.");
	}
	else {
		$window->set_status("Click on the tiles you want to replace, then click Replace Tiles again.");
	}

	$window->{canvas}->replace_tiles();
}

sub _pass_turn_callback {
	my ($button, $window) = @_;

	$window->set_status("You have passed your turn. Making AI move...");

	$window->{canvas}->return_tiles_to_rack();
	$window->{canvas}->next_turn();

	$window->{passcount}++;

	$window->make_ai_move();
}

sub _ai_timer_callback {
	my ($self) = @_;

	if ($self->{make_ai_move}) {
		$self->{make_ai_move} = 0;

		my $aimove = $self->{game}->get_ai_move();

		if ($aimove) {
			my @words = @{$aimove->get_words()};
			$self->set_status(sprintf('AI has played "%s" for %d points.', $words[0], $aimove->evaluate()));

			$self->{canvas}{board}->move_to_board($aimove);
			$self->{canvas}{board}->commit_spaces();

			$self->{passcount} = 0;

			$self->set_disabled(0);
		}
		else {
			if ($self->{passcount}) {
				$self->end_game();
			}
			else {
				$self->set_status("AI was unable to make a move. It is now your turn.");
				$self->set_disabled(0);
			}
		}

		$self->{canvas}->next_turn();
		$self->refresh_gameinfo();
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

sub _difficulty_callback {
	my ($button, $data) = @_;

	if ($button->get_active()) {
		my $window = $data->{window};
		my $difficulty = $data->{difficulty};

		$window->{difficulty} = $difficulty;
	}
}

1;
