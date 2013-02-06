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

1;
