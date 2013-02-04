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
		'3w' => [
			'0,0',
			'7,0',
			'14,0',
			'14,7',
			'14,14',
			'7,14',
			'0,14',
			'0,7',
		],
		'2w' => [
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

1;
