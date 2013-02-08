package Library;

use strict;
use warnings;

use Data::Dumper;

# use Algorithm::Permute;
# use Algorithm::Combinatorics;

use Node;

sub new {
	my ($class) = @_;
	
	print "Reading wordlists\n";
	my $self = bless({
		shortwords => hashref_from_wordlist('ospd.txt'),
		longwords => hashref_from_wordlist('enable.txt'),
		testwords => hashref_from_wordlist('test.txt'),
	}, $class);
	
	# Generate tree from the shortwords list plus all the words in longwords that
	# are more than 8 characters.
	print "getting treebase\n";
	my @treebase = keys %{$self->{shortwords}};
	print "Adding words to treebase\n";
	for my $word ( keys %{$self->{longwords}} ) {
		push (@treebase, $word) if length($word) > 8;
	}
	print "Building tree\n";
	$self->{wordtree} = build_tree(\@treebase);
	print "Done building tree\n";
	return $self;
}

sub hashref_from_wordlist {
	my ($filename) = @_;
	
	my $hashref = {};
	
	open(FILE, $filename);
	while (<FILE>) {
		chomp;
		$hashref->{$_} = 1 if length > 0;
	}
	close(FILE);
	
	return $hashref;
}

# Takes an arrayref of words and returns the top Node of the tree representation
sub build_tree {
	my ($words) = @_;
	
	my $tree = Node->new();
	for my $word (@$words) {
		my @letters = split('', $word);
		$tree->add_word(\@letters);
	}
	
	return $tree;
}

sub is_common_word {
	my ($self, $word) = @_;
	
	return defined($self->{shortwords}{lc($word)});
}

sub is_legal_word {
	my ($self, $word) = @_;
	
	return defined($self->{longwords}{lc($word)});
}

# $input is a string.
# Returns a hashref of all the legal scrabble words (of any length) that can be made out
# of the letters in $input.
#sub get_legal_words {
	#my ($self, $input) = @_;
	
	#my @letterarray = split('', $input);
	#my %words;
	
	## We need all combinations of letters in the input from a length of 1 up to
	## the length of the input because you don't have to use all your letters
	## when making a word.
	#for my $k (2..$#letterarray) {
		
		## Now iterate through all the combinations of length $k
		#my $c_iterator = Algorithm::Combinatorics::combinations(\@letterarray, $k);
		#while (my $combination = $c_iterator->next) {
			
			## For this combination, get all the permutations of the letters,
			## then check if that word is legal.
			#my $p_iterator = Algorithm::Permute->new($combination);
			#while (my @perm = $p_iterator->next) {
				#my $word = join('', @perm);
				#$words{$word} = 1 if $self->is_common_word($word);
			#}
		#}
	#}

    #return [keys(%words)];
#}

1;
