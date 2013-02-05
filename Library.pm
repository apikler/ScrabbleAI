package Library;

use strict;
use warnings;

use Data::Dumper;

use Algorithm::Permute;
use Algorithm::Combinatorics;

sub new {
	my ($class) = @_;
	
	my $self = bless({
		wordlist => hashref_from_wordlist('ospd.txt'),
		allwords => hashref_from_wordlist('enable.txt'),
	}, $class);
	
	return $self;
}

sub hashref_from_wordlist {
	my ($filename) = @_;
	
	my $hashref = {};
	
	open(FILE, $filename);
	while (<FILE>) {
		chomp;
		$hashref->{$_} = 1;
	}
	close(FILE);
	
	return $hashref;
}

sub is_common_word {
	my ($self, $word) = @_;
	
	return defined($self->{wordlist}{lc($word)});
}

sub is_legal_word {
	my ($self, $word) = @_;
	
	return defined($self->{allwords}{lc($word)});
}

# $input is a string.
# Returns a hashref of all the legal scrabble words (of any length) that can be made out
# of the letters in $input.
sub get_legal_words {
	my ($self, $input) = @_;
	
	my @letterarray = split('', $input);
	my %words;
	
	# We need all combinations of letters in the input from a length of 1 up to
	# the length of the input because you don't have to use all your letters
	# when making a word.
	for my $k (2..$#letterarray) {
		
		# Now iterate through all the combinations of length $k
		my $c_iterator = Algorithm::Combinatorics::combinations(\@letterarray, $k);
		while (my $combination = $c_iterator->next) {
			
			# For this combination, get all the permutations of the letters,
			# then check if that word is legal.
			my $p_iterator = Algorithm::Permute->new($combination);
			while (my @perm = $p_iterator->next) {
				my $word = join('', @perm);
				$words{$word} = 1 if $self->is_common_word($word);
			}
		}
	}

    return [keys(%words)];
}

1;
