package Library;

use strict;
use warnings;

use Data::Dumper;
use Storable;

use Node;

sub new {
	my ($class) = @_;
	
	my $self = bless({
		shortwords => hashref_from_wordlist('ospd.txt'),
		longwords => hashref_from_wordlist('enable.txt'),
		testwords => hashref_from_wordlist('test.txt'),
	}, $class);
	
	# Generate tree from the shortwords list plus all the words in longwords that
	# are more than 8 characters.
	my @treebase = keys %{$self->{shortwords}};
	for my $word ( keys %{$self->{longwords}} ) {
		push (@treebase, $word) if length($word) > 8;
	}
	
	if (-e 'library') {
		$self->{wordtree} = retrieve('library');
	}
	else {
		$self->{wordtree} = build_tree(\@treebase);
		
		store($self->{wordtree}, 'library');
	}
	
	$self->{treewords} = {};
	for my $word (@treebase) {
		$self->{treewords}{$word} = 1;
	}
	
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

sub is_tree_word {
	my ($self, $word) = @_;
	
	return defined($self->{treewords}{lc($word)});
}

1;
