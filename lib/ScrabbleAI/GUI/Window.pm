##########################################################################
# ScrabbleAI::GUI::Window
# The main window. Can have two modes, 'intro' or 'game', corresponding
# to the screen where the user selects the difficulty and to the main
# game screen, respectively.
#
# Copyright (C) 2015 Andrew Pikler
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

package ScrabbleAI::GUI::Window;

use strict;
use warnings;

use Gtk2 '-init';
use Gnome2::Canvas;
use Glib;

use base qw(Gtk2::Window);

use ScrabbleAI::Backend::Game;
use ScrabbleAI::Backend::Utils;
use ScrabbleAI::GUI::Canvas;
use ScrabbleAI::GUI::GameInfoFrame::Scoreboard;
use ScrabbleAI::GUI::GameInfoFrame::TileCount;
use ScrabbleAI::GUI::Key;
use ScrabbleAI::GUI::LargeImageButton;
use ScrabbleAI::GUI::SettingsManager;

use Data::Dumper;

use constant {
	DEFAULT_INTRO_SIZE => [450, 400],
	DEFAULT_GAME_SIZE => [700, 700],
	DEFAULT_DIFFICULTY => 5,
	MINIMUM_WIDTH => 400,
};

# The HTML used in the 'help' popup
my $HELP_MARKUP = <<'MARKUP';
This game follows the rules of Scrabble, the popular word game. If you are unfamiliar
with its rules, please take some time to look them up online.

The game begins with your turn; you will need to click and drag tiles from your rack
to create a word, one letter of which must lie on the middle tile of the board.
Once you click "Make Move", your move will be scored, and the AI will make a move.
Turns will alternate until no more moves can be made, at which point the game ends.

<b>Blank Tiles</b> - To set the letter on a blank tile, right click it, and then
press the key on your keyboard corresponding to the letter you desire. You may
also hit any non-letter key to reset the tile to its blank state.

The following four buttons appear to the right of the game board:

<b>Pass Turn</b> - Skips your turn. Use this if you cannot make a move (for example,
if you have no more letters left).

<b>Replace Tiles</b> - Allows you to pick tiles from your rack to replace with new
tiles from the bag. This action uses up your turn.

<b>Return Tiles to Rack</b> - Returns to your rack any tiles you have placed onto
the board this turn.

<b>Make Move</b> - Attempts to make a move based on the letters you have played.
Your move will be rejected if it is illegal or contains invalid words, but you
will not be penalized.

Thank you for playing, and enjoy your game!
MARKUP

# The HTML used in the 'about' popup
my $ABOUT_MARKUP = <<'MARKUP';
Copyright (C) 2015 Andrew Pikler

<b>Other Credits:</b>
AI based on a paper by Andrew W. Appel and Guy J. Jacobson, "The
World's Fastest Scrabble Program", May 1988.

Some icons used from flaticon.com.
MARKUP

sub new {
	my ($class) = @_;
	
	my $self = $class->SUPER::new();
	bless($self, $class);
	
	$self->set_size_request(MINIMUM_WIDTH, -1);

	$self->{settings_manager} = ScrabbleAI::GUI::SettingsManager->new();
	$self->load_settings();

	my $position = $self->{settings}{position};
	$self->move(@$position) if $position;

	my $intro_size = $self->{settings}{intro_size};
	$self->set_default_size($intro_size->[0], $intro_size->[1]);

	$self->set_title('ScrabbleAI');
	$self->set_icon_list(Gtk2::Gdk::Pixbuf->new_from_file(ScrabbleAI::Backend::Utils::abs_path('GUI/images/s_tile.png')));
	$self->signal_connect(destroy => \&_destroy_callback);

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

	$self->draw_version('intro');

	$self->signal_connect(configure_event => \&_resize_callback);

	return $self;
}

# Loads window position, window size, and difficulty settings that have
# been saved by the ScrabbleAI::GUI::SettingsManager
sub load_settings {
	my ($self) = @_;

	my %settings;
	my $saved = $self->{settings_manager};

	# Window position
	$settings{position} = $saved->get('position');

	# Size of the intro window
	$settings{intro_size} = $saved->get('intro_size', DEFAULT_INTRO_SIZE);

	# Size of the main game window
	$settings{game_size} = $saved->get('game_size', DEFAULT_GAME_SIZE);

	# Difficulty
	$settings{difficulty} = $saved->get('difficulty', DEFAULT_DIFFICULTY);

	$self->{settings} = \%settings;
}

# Draws the indicated version (screen) of the window. $version must be "game" or "intro".
sub draw_version {
	my ($self, $version) = @_;

	$self->destroy();
	my $vbox_main = $self->{vbox_main};

	if (lc($version) eq 'game') {
		$self->{version} = 'game';

		my $size = $self->{settings}->{game_size};
		$self->resize($size->[0], $size->[1]);

		unless ($self->{game}) {
			$self->{game} = ScrabbleAI::Backend::Game->new();
		}
		$self->{game}->reset($self->{settings}{difficulty});

		my $vbox_widgets = Gtk2::VBox->new(0, 6);
		my $hbox = Gtk2::HBox->new(0, 6);

		$vbox_main->pack_start($hbox, 1, 1, 0);
		$self->{canvas} = ScrabbleAI::GUI::Canvas->new($self, $self->{game});
		$hbox->pack_start($self->{canvas}, 1, 1, 0);

		# Left Panel ---------------------------------------------------
		my @buttons;
		$hbox->pack_start($vbox_widgets, 0, 0, 0);

		# "Make Move" button
		my $turn_button = ScrabbleAI::GUI::LargeImageButton->new(
			Gtk2::Image->new_from_stock('gtk-apply', 'dialog'),
			"<span size=\"x-large\">Make\nMove</span>",
		);
		$vbox_widgets->pack_end($turn_button, 1, 1, 0);
		$turn_button->signal_connect(clicked => \&_make_move_callback, $self->{canvas});
		push(@buttons, $turn_button);

		my $scoreboard = ScrabbleAI::GUI::GameInfoFrame::Scoreboard->new($self->{game});
		$vbox_widgets->pack_start($scoreboard, 0, 0, 0);
		$self->{scoreboard} = $scoreboard;

		my $tilecount = ScrabbleAI::GUI::GameInfoFrame::TileCount->new($self->{game});
		$vbox_widgets->pack_start($tilecount, 0, 0, 0);
		$self->{tilecount} = $tilecount;

		my $key = ScrabbleAI::GUI::Key->new();
		$vbox_widgets->pack_start($key, 0, 0, 0);

		my $pass_button = Gtk2::Button->new(' Pass Turn');
		$pass_button->set_image(Gtk2::Image->new_from_stock('gtk-media-forward', 'menu'));
		$pass_button->set_size_request(-1, 35);
		$vbox_widgets->pack_start($pass_button, 0, 0, 0);
		$pass_button->signal_connect(clicked => \&_pass_turn_callback, $self);
		push(@buttons, $pass_button);

		my $replace_button = Gtk2::Button->new(' Replace Tiles');
		$replace_button->set_image(Gtk2::Image->new_from_stock('gtk-refresh', 'menu'));
		$replace_button->set_size_request(-1, 35);
		$vbox_widgets->pack_start($replace_button, 0, 0, 0);
		$replace_button->signal_connect(clicked => \&_replace_tiles_callback, $self);
		push(@buttons, $replace_button);
		$self->{replace_button} = $replace_button;

		$vbox_widgets->pack_start(Gtk2::SeparatorMenuItem->new(), 0, 0, 0);

		my $return_button = ScrabbleAI::GUI::LargeImageButton->new(
			Gtk2::Image->new_from_stock('gtk-undo', 'dialog'),
			"<span size=\"x-large\">Return Tiles\nto Rack</span>",
		);
		$vbox_widgets->pack_end($return_button, 1, 1, 0);
		$return_button->signal_connect(clicked => \&_return_tiles_callback, $self);
		push(@buttons, $return_button);

		$self->signal_connect(key_press_event => \&_handle_key, $self->{canvas});
		# End Left Panel ---------------------------------------------------

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
		$self->{version} = 'intro';

		my $size = $self->{settings}->{intro_size};
		$self->resize($size->[0], $size->[1]);

		my $hbox = Gtk2::HBox->new(1, 0);
		$vbox_main->pack_start($hbox, 1, 1, 0);

		my $frame = Gtk2::Frame->new("Difficulty");
		$hbox->pack_start($frame, 1, 1, 0);

		my $vbox_difficulty = Gtk2::VBox->new();
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

			if ($difficulty == $self->{settings}{difficulty}) {
				$button->set_active(1);
			}

			$button->signal_connect(toggled => \&_difficulty_callback, {
				window => $self,
				difficulty => $difficulty,
			});
		}

		my $button = ScrabbleAI::GUI::LargeImageButton->new(
			Gtk2::Image->new_from_file(ScrabbleAI::Backend::Utils::abs_path('GUI/images/start.png')),
			"<span size=\"50000\">Start\nGame</span>",
		);
		$hbox->pack_end($button, 1, 1, 0);

		push(@{$self->{widgets}}, $hbox);

		$button->signal_connect(clicked => sub { $self->draw_version('game'); });
	}

	$self->show_all();
}

# Draws the menus at the top of the window
sub draw_menu_bar {
	my ($self, $box) = @_;
	
	my $menubar = Gtk2::MenuBar->new();
	$self->{menubar} = $menubar;
	
	# 'File' menu
	my $filemenu = Gtk2::Menu->new();

	my $new_game_item = Gtk2::ImageMenuItem->new('_New Game');
	$new_game_item->set_image(Gtk2::Image->new_from_stock('gtk-new', 'menu'));
	$new_game_item->signal_connect(activate => sub { $self->draw_version('intro'); });
	$filemenu->append($new_game_item);

	$filemenu->append(Gtk2::SeparatorMenuItem->new());

	my $quit_item = Gtk2::ImageMenuItem->new_from_stock('gtk-quit', undef);
	$quit_item->signal_connect(activate => sub { $self->_destroy_callback(); });
	$filemenu->append($quit_item);
	
	my $filemenu_item = Gtk2::MenuItem->new('_File');
	$filemenu_item->set_submenu($filemenu);
	$menubar->append($filemenu_item);
	
	# 'Help' menu
	my $helpmenu = Gtk2::Menu->new();
	my $help_item = Gtk2::ImageMenuItem->new_from_stock('gtk-help', undef);
	$help_item->signal_connect(activate => sub { $self->simple_dialog('Help', $HELP_MARKUP); });
	$helpmenu->append($help_item);

	my $about_item = Gtk2::ImageMenuItem->new_from_stock('gtk-about', undef);
	$about_item->signal_connect(activate => sub { $self->simple_dialog('About', $ABOUT_MARKUP); });
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

# Destroys the widgets referenced in $self->{widgets}. Called when switching between the intro
# and game screens
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

# So as to not freeze widget elements as the AI is computing its next move, there is a timer running
# that checks every second if an AI move needs to be made. Calling this function sets a flag such
# that the AI will make a move at the next check of the timer.
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

# Displays a simple popup dialog with the given title and markup.
sub simple_dialog {
	my ($self, $title, $markup) = @_;

	my $dialog = Gtk2::Dialog->new($title, $self, 'destroy-with-parent',
		'gtk-close' => 'close',
	);

	my $label = Gtk2::Label->new();
	$label->set_markup($markup);
	$dialog->get_content_area()->add($label);

	$dialog->show_all();
	$dialog->run();
	$dialog->destroy();
}

# "Make Move" button callback
sub _make_move_callback {
	my ($button, $canvas) = @_;

	$canvas->make_move();
}

# "Return Tiles to Rack" button callback
sub _return_tiles_callback {
	my ($button, $window) = @_;

	$window->{canvas}->return_tiles_to_rack();
}

# "Replae Tiles" button callback
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

# "Pass Turn" button callback
sub _pass_turn_callback {
	my ($button, $window) = @_;

	$window->set_status("You have passed your turn. Making AI move...");

	$window->{canvas}->return_tiles_to_rack();
	$window->{canvas}->next_turn();

	$window->{passcount}++;

	$window->make_ai_move();
}

# Timer callback for checking if an AI move needs to be made. See $self->make_ai_move().
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

# Key press callack; used for changing the letter on a blank tile.
sub _handle_key {
	my ($widget, $event, $canvas) = @_;

	# If we're changing the letter on a blank tile, make sure the key is between A and Z.
	my $keyval = $event->keyval();
	my $tile = $canvas->{selected_blank_tile};
	if ($tile) {
		if (($keyval >= 97 && $keyval <= 122) || ($keyval >= 65 && $keyval <= 90)) {
			my $letter = lc(chr($keyval));
			$tile->get_tile()->set_blank_letter($letter);
			$canvas->{window}->set_status(sprintf("You have set the blank tile to %s.", uc($letter)));
		}
		else {
			$tile->get_tile()->set_blank_letter('*');
			$canvas->{window}->set_status("You have reset the blank tile.");
		}

		$tile->refresh_text();
		delete $canvas->{selected_blank_tile};
	}
}

# Callback when a new difficulty is selected on the intro screen via the radio buttons
sub _difficulty_callback {
	my ($button, $data) = @_;

	if ($button->get_active()) {
		my $window = $data->{window};
		my $difficulty = $data->{difficulty};

		$window->{settings}{difficulty} = $difficulty;
	}
}

sub _resize_callback {
	my ($window) = @_;

	return unless defined $window->{version};

	$window->{settings}{sprintf('%s_size', $window->{version})} = [$window->get_size()];
	$window->{settings}{position} = [$window->get_position()];

	return 0;
}

# This gets called when we're exiting the game; save settings here.
sub _destroy_callback {
	my ($window) = @_;

	$window->{settings_manager}->set($window->{settings});
	$window->{settings_manager}->save();

	Gtk2->main_quit();
}

1;
