package Backend::Library;

use strict;
use warnings;

use Data::Dumper;
use Storable;

use Backend::Utils;
use Backend::Node;

use constant {
	OSPD => Backend::Utils::abs_path('Backend/ospd.txt'),
	ENABLE => Backend::Utils::abs_path('Backend/enable.txt'),
	LIBRARY => Backend::Utils::abs_path('Backend/library'),
};

sub new {
	my ($class) = @_;
	
	my $self = bless({
		shortwords => hashref_from_wordlist(OSPD),
		longwords => hashref_from_wordlist(ENABLE),
	}, $class);
	
	# Generate tree from the shortwords list plus all the words in longwords that
	# are more than 8 characters.
	my @treebase = keys %{$self->{shortwords}};
	for my $word ( keys %{$self->{longwords}} ) {
		push (@treebase, $word) if length($word) > 8;
	}
	
	if (-e LIBRARY) {
		$self->{wordtree} = retrieve(LIBRARY);
	}
	else {
		$self->{wordtree} = build_tree(\@treebase);
		
		store($self->{wordtree}, LIBRARY);
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
	
	my $tree = Backend::Node->new();
	for my $word (@$words) {
		my @letters = split('', $word);
		$tree->add_word(\@letters);
	}
	
	return $tree;
}

# Returns the top-level node of the word tree.
sub get_tree {
	my ($self) = @_;
	
	return $self->{wordtree};
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
