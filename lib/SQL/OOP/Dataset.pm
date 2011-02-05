package SQL::OOP::Dataset;
use strict;
use warnings;
use SQL::OOP;
use base qw(SQL::OOP);
our $VERSION = '0.03';
	
	sub MODE_INSERT() {1} ## no critic
	sub MODE_UPDATE() {2} ## no critic
	
	### ---
	### コンストラクタ
	### ---
	sub new {
		
		my $class = shift @_;
		my $data_hash_ref = (scalar @_ == 1) ? shift @_ : {@_};
		my $self = bless {
			gen 	=> undef,
			field	=> [],
			value	=> [],
			bind	=> [],
		}, $class;
		
        return $self->append($data_hash_ref);
	}
	
	### ---
	### 要素の追加
	### ---
	sub append {
		
		my $self = shift @_;
		my $data_hash_ref = (scalar @_ == 1) ? shift @_ : {@_};
		$self->_init_gen;
		
		for my $key (keys %$data_hash_ref) {
			push(@{$self->{field}}, (SQL::OOP::ID->new($key)->to_string));
			push(@{$self->{bind}}, $data_hash_ref->{$key});
		}
		
		return $self;
	}
	
	### ---
	### SQLスニペットを得る
	### ---
	sub to_string_for_update {
		
		my ($self, $prefix) = @_;
		$self->generate(MODE_UPDATE);
		if ($self->{gen} && $prefix) {
			return $prefix. ' '. $self->{gen};
		} else {
			return $self->{gen};
		}
	}
	
	sub to_string_for_insert {
		
		my ($self, $prefix) = @_;
		$self->generate(MODE_INSERT);
		if ($self->{gen} && $prefix) {
			return $prefix. ' '. $self->{gen};
		} else {
			return $self->{gen};
		}
	}
	
	sub generate {
		
		my ($self, $type) = @_;
		if ($type eq MODE_INSERT) {
			$self->{gen} = '(';
			$self->{gen} .= join(', ', grep {$_} @{$self->{field}});
			$self->{gen} .= ') VALUES (';
			$self->{gen} .= join(', ', map {'?'} @{$self->{field}});
			$self->{gen} .= ')';
		} elsif ($type eq MODE_UPDATE) {
			$self->{gen} = join(', ', map {$_. ' = ?'} @{$self->{field}});
		}
		return $self;
	}

1;

__END__

=head1 NAME

SQL::OOP::Dataset

=head1 SYNOPSIS

=head1 DESCRIPTION

SQL::OOP::Dataset is a class which represents data sets for INSERT or UPDATE

=head1 METHODS

=head2 new

=head2 append

=head2 generate

=head2 to_string_for_insert

=head2 to_string_for_update

=head1 CONSTANTS

=head2 MODE_INSERT

insert mode(=1)

=head2 MODE_UPDATE

insert mode(=2)

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
