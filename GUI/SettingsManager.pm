package GUI::SettingsManager;

use strict;
use warnings;

use Backend::Utils;

use Data::Dumper;
use Storable;

use constant FILENAME => Backend::Utils::abs_path('GUI/settings');

sub new {
	my ($class) = @_;

	my $self = bless({
		settings => {},
	}, $class);

	# If the settings file exists, load its contents.
	if (-e FILENAME) {
		$self->{settings} = retrieve(FILENAME);
	}

	return $self;
}

sub get {
	my ($self, $key, $default) = @_;

	if (defined $self->{settings}{$key}) {
		return $self->{settings}{$key};
	}
	else {
		if (defined $default) {
			return $default;
		}
		else {
			return undef;
		}
	}
}

sub set {
	my ($self, $new_settings) = @_;

	while (my ($key, $value) = each %$new_settings) {
		$self->{settings}{$key} = $value;
	}
}

sub clear {
	my ($self) = @_;

	$self->{settings} = {};
}

sub save {
	my ($self) = @_;

	store($self->{settings}, FILENAME);
}

1;
