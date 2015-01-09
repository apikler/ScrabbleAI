##########################################################################
# Backend::Library
# A helper class that is used in AI move generation and in telling if
# a word is valid to play.
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

package Backend::Library;

use strict;
use warnings;

use Data::Dumper;
use Storable;

use Backend::Utils;
use Backend::Node;

# We use two different lists of words:
#	ospd.txt - a shorter list
#	enable.txt - a longer, more complete list, used mainly for checking if words
#		played by the human player are valid. Also contains some long English words that
#		ospd does not.
use constant {
	OSPD => Backend::Utils::abs_path('Backend/ospd.txt'),
	ENABLE => Backend::Utils::abs_path('Backend/enable.txt'),
	LIBRARY => Backend::Utils::abs_path('Backend/library'),
};

# If a Backend/Library file exists, attempts to load the Library from it using Storable.
# Otherwise, generates a new Backend/Library file from ospd.txt and enable.txt.
#
# The words used by the AI to generate moves are the ones from ospd.txt, with the addition of
# only the longer words from enable.txt (as the former does not contain long words).
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

# Converts a file containing a list of words into a hash for quick lookups.
#	$filename: Path to the file to read from
#	Return value: a hashref with entries in the form of {word => 1}
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

# Returns the top-level Node of the word tree.
sub get_tree {
	my ($self) = @_;
	
	return $self->{wordtree};
}

# Returns 1 if the given word appears in OSPD; 0 otherwise. (Case-insensitive)
sub is_common_word {
	my ($self, $word) = @_;
	
	return defined($self->{shortwords}{lc($word)});
}

# Returns 1 if the given word appears in Enable; 0 otherwise. (Case-insensitive)
sub is_legal_word {
	my ($self, $word) = @_;
	
	return defined($self->{longwords}{lc($word)});
}

# Returns 1 if the given word appears in the word tree (the words that the AI can play);
# 0 otherwise. (Case-insensitive)
sub is_tree_word {
	my ($self, $word) = @_;
	
	return defined($self->{treewords}{lc($word)});
}

1;
