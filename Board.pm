package Board;

use strict;
use warnings;

use Space;

sub new {
	my ($class) = @_;
	
	my $self = bless({}, $class);
	$self->reset();
	
	return $self;
}

sub reset {
	my ($self) = @_;
	
	my %bonuses_by_type = (
		'3W' => [
			'0,0',
			'7,0',
			'14,0',
			'14,7',
			'14,14',
			'7,14',
			'0,14',
			'0,7',
		],
		'2W' => [
			'7,7',
			'1,1',
			'2,2',
			'3,3',
			'4,4',
			'13,1',
			'12,2',
			'11,3',
			'10,4',
			'13,13',
			'12,12',
			'11,11',
			'10,10',
			'1,13',
			'2,12',
			'3,11',
			'4,10',
		],
		'3L' => [
			'5,1',
			'9,1',
			'1,5',
			'5,5',
			'9,5',
			'13,5',
			'1,9',
			'5,9',
			'9,9',
			'13,9',
			'5,13',
			'9,13',
		],
		'2L' => [
			'3,0',
			'11,0',
			'6,2',
			'8,2',
			'0,3',
			'7,3',
			'14,3',
			'2,6',
			'6,6',
			'8,6',
			'12,6',
			'3,7',
			'11,7',
			'2,8',
			'6,8',
			'8,8',
			'12,8',
			'0,11',
			'7,11',
			'14,11',
			'6,12',
			'8,12',
			'3,14',
			'11,14',
		],
	);
	
	my %bonuses_by_space;
	for my $bonus_type (keys %bonuses_by_type) {
		for my $space (@{$bonuses_by_type{$bonus_type}}) {
			$bonuses_by_space{$space} = $bonus_type;
		}
	}
	
	my %spaces = ();
	
	for my $i (0..14) {
		for my $j (0..14) {
			my $space = "$i,$j";
			my $bonus = $bonuses_by_space{$space};
			$spaces{$space} = $bonus ? Space->new($bonus) : Space->new('');
		}
	}

	$self->{spaces} = \%spaces;
}

sub get_space {
	my ($self, $i, $j) = @_;
	
	return $self->{spaces}{"$i,$j"};
}

# Prints a human-readable representation of the bonuses on the board.
# Doesn't print any tiles that may be on the board.
sub print_bonuses {
	my ($self) = @_;
	
	for my $i (0..14) {
		for my $j (0..14) {
			my $bonus = $self->get_space($i, $j)->get_bonus();
			print $bonus ? "$bonus " : '** ';
		}
		print "\n";
	}
}

sub print_spaces {
	my ($self) = @_;
	
	for my $i (0..14) {
		for my $j (0..14) {
			$self->get_space($i, $j)->print();
			print " ";
		}
		print "\n";
	}
}

1;
