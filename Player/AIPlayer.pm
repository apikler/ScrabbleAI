package Player::AIPlayer;
use base qw(Player);

use strict;
use warnings;

use Data::Dumper;

use Tile;

sub new {
	my ($class, $board, $library) = @_;
	
	my $self = Player->new($board);
	
	bless($self, $class);
	$self->{library} = $library;
	
	return $self;
}

sub get_move {
	my ($self) = @_;
	
	my $restrictions = $self->get_restrictions();
	
	my %toprint;
	for my $index (keys %$restrictions) {
		$toprint{$index} = $restrictions->{$index} if @{$restrictions->{$index}};
	}
	print Dumper(\%toprint);
}

# Cross-checks. Returns a hashref of
# {'i,j' => arrayref of allowed letters}
# where "allowed letters" is an arrayref of letters that can be placed
# in the space at i,j to create a legal word vertically.
# An empty arrayref means any tile is allowed.
sub get_restrictions {
	my ($self) = @_;
	
	my $letters = Tile::get_allowed_letters();
	my %restrictions;
	
	$self->{board}->foreach_space(sub {
		my ($space, $i, $j) = @_;
		my $index = "$i,$j";
		
		# No need to get restrictions if this space has a tile.
		if ($space->get_tile()) {
			$restrictions{$index} = [];
			return;
		}
		
		my $top_tiles = $self->{board}->get_letters_in_direction($i, $j, 0, -1);
		my $top_letters = join('', map {$_->get()} @$top_tiles);
		my $bottom_tiles = $self->{board}->get_letters_in_direction($i, $j, 0, 1);
		my $bottom_letters = join('', map {$_->get()} @$bottom_tiles);
		
		if (length($top_letters.$bottom_letters) > 0) {
			# Cycle through all the valid letters to see which ones make a valid
			# word with the adjacent tiles
			
			my @restriction;
			for my $letter (@$letters) {
				if ($self->{library}->is_tree_word($top_letters.$letter.$bottom_letters)) {
					push (@restriction, $letter);
				}
			}
			
			$restrictions{$index} = \@restriction;
		}
		else {
			# There are no tiles vertically adjacent to this space, so there are no restrictions.
			$restrictions{$index} = [];
		}
	});
	
	return \%restrictions;
}

1;
