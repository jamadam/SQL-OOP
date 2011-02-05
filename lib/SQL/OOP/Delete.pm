package SQL::OOP::Delete;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use base qw(SQL::OOP::Command);

	sub ARG_TABLE() {1} ## no critic
	sub ARG_WHERE() {2} ## no critic
	
	### ---
	### Get Names of set arguments in array ref
	### ---
	sub KEYS {
		
		return [ARG_TABLE, ARG_WHERE];
	}
	
	### ---
	### Get prefixes for each clause in hash ref
	### ---
	sub PREFIXES {
		
		return {
			ARG_TABLE() => 'DELETE FROM',
			ARG_WHERE() => 'WHERE',
		}
	}
	
	### ---
	### Constractor
	### ---
	sub new {
		
		my ($class, %hash) = @_;
		return $class->SUPER::new(%hash);
	}
	
	### ---
	### Set elements
	### ---
	sub set {
		
		my ($class, %hash) = @_;
		return $class->SUPER::set(%hash);
	}
	
	### ---
	### Get SQL snippet
	### ---
	sub to_string {
		
		return shift->SUPER::to_string(@_);
	}
	
	### ---
	### Get binded values in array
	### ---
	sub bind {
		
		return shift->SUPER::bind(@_);
	}

1;

__END__

=head1 NAME

SQL::OOP::Delete

=head1 SYNOPSIS
    
    use SQL::OOP::Delete;
    
    my $delete= SQL::OOP::Delete->new();
    
    # set clause
    $delete->set(
        $delete->ARG_TABLE => 'some_table',
        $delete->ARG_WHERE => SQL::OOP::Where->cmp('=', 'a', 'b'),
    );
    
    # reset clause by plain text
    $delete->set(
        $delete->ARG_WHERE => 'a = b'
    );
    
    my $sql  = $delete->to_string;
    my @bind = $sth->execute($delete->bind);

=head1 DESCRIPTION

SQL::OOP::Delete class represents Delete commands.

=head1 METHODS

=head2 new

=head2 set

=head2 to_string

=head2 bind

=head1 CONSTANTS

=head2 ARG_TABLE

argument key for table name(=1)

=head2 ARG_WHERE

argument key for where clause(=2)

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
