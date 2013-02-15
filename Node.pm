package Node;

use strict;
use warnings;

use Data::Dumper;

sub new {
	my ($class) = @_;
	
	# children is a hashref of character => Node
	my $self = bless({
		children => {},
		endpoint => 0,
	}, $class);
	
	return $self;
}

# If this node has a child Node at that given letter, returns that Node.
# Otherwise returns undef.
sub get_child {
	my ($self, $letter) = @_;
	
	return defined($self->{children}{$letter}) ? $self->{children}{$letter} : undef;
}

sub get_edges {
	my ($self) = @_;
	
	return [keys %{$self->{children}}];
}

# Adds the given Node as a child at $letter. Overwrites any existing child for
# that letter.
sub set_child {
	my ($self, $letter, $node) = @_;
	
	$self->{children}{$letter} = $node;
}

# Adds the $letters (taken as an arrayref of characters, for speed purposes)
# to the tree.
sub add_word {
	my ($self, $letters) = @_;

	unless (@$letters) {
		$self->set_endpoint();
		return;
	}
	
	my $letter = shift(@$letters);
	my $child = $self->get_child($letter);
	unless ($child) {
		$child = $self->set_child($letter, Node->new());
	}
	
	$child->add_word($letters);
}

sub set_endpoint {
	my ($self) = @_;
	
	$self->{endpoint} = 1;
}

sub is_endpoint {
	my ($self) = @_;
	
	return $self->{endpoint};
}

# Traverse the tree, from the given node, using the path in the prefix (an array of characters).
# Returns the resulting node, or undef if the traversal isn't possible.
sub get_node {
	my ($node, @prefix) = @_;
	
	return $node unless @prefix;
	
	my $edge = shift @prefix;
	if (my $child = $node->get_child($edge)) {
		return get_node($child, @prefix);
	}
	else {
		return undef;
	}
}

1;
