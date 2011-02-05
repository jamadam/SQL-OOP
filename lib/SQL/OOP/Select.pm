package SQL::OOP::Select;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use base qw(SQL::OOP::Command);

	sub ARG_FIELDS()	{1} ## no critic
	sub ARG_FROM()		{2} ## no critic
	sub ARG_WHERE()		{3} ## no critic
	sub ARG_GROUPBY()	{4} ## no critic
	sub ARG_ORDERBY()	{5} ## no critic
	sub ARG_LIMIT()		{6} ## no critic
	sub ARG_OFFSET()	{7} ## no critic
	
	### ---
	### Get Names of set arguments in array ref
	### ---
	sub KEYS {
		
		return
		[ARG_FIELDS, ARG_FROM, ARG_WHERE,
		 ARG_GROUPBY, ARG_ORDERBY, ARG_LIMIT, ARG_OFFSET];
	}
	
	### ---
	### Get prefixes for each clause in hash ref
	### ---
	sub PREFIXES {
		
		return {
			ARG_FIELDS() 	=> 'SELECT',
			ARG_FROM() 		=> 'FROM',
			ARG_WHERE()		=> 'WHERE',
			ARG_GROUPBY()	=> 'GROUP BY',
			ARG_ORDERBY() 	=> 'ORDER BY',
			ARG_LIMIT()		=> 'LIMIT',
			ARG_OFFSET()	=> 'OFFSET',
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

package SQL::OOP::Order;
use SQL::OOP;
use base qw(SQL::OOP::Array);
	
	### ---
	### Constractor
	### ---
	sub new {
		
		my ($class, @array) = @_;
        return $class->SUPER::new(@array)->set_sepa(', ');
	}
    
    sub abstract {
        
        my ($class, $array_ref) = @_;
        my $self = $class->SUPER::new()->set_sepa(', ');
        foreach my $rec_ref (@{$array_ref}) {
            if ($rec_ref->[1]) {
                $self->append_desc($rec_ref->[0]);
            } else {
                $self->append_asc($rec_ref->[0]);
            }
        }
        return $self;
    }
	
	### ---
	### Get SQL::OOP::Order::Expression instance(ASC)
	### ---
	sub new_asc {
		
		my ($class_or_obj, $key) = @_;
		return SQL::OOP::Order::Expression->new($key);
	}
	
	### ---
	### Get SQL::OOP::Order::Expression instance(DESC)
	### ---
	sub new_desc {
		
		my ($class_or_obj, $key) = @_;
		return SQL::OOP::Order::Expression->new_desc($key);
	}
	
	### ---
	### Append element(ASC)
	### ---
	sub append_asc {
		
		my ($self, $key) = @_;
		$self->_init_gen;
		push(@{$self->{array}}, SQL::OOP::Order::Expression->new($key));
		return $self;
	}
	
	### ---
	### Append element(DESC)
	### ---
	sub append_desc {
		
		my ($self, $key) = @_;
		$self->_init_gen;
		push(@{$self->{array}}, SQL::OOP::Order::Expression->new_desc($key));
		return $self;
	}

package SQL::OOP::Order::Expression;
use strict;
use warnings;
use base qw(SQL::OOP);

	### ---
	### Constractor
	### ---
	sub new {
		
		my ($class, $key) = @_;
		if ($key) {
			return $class->SUPER::new(SQL::OOP::ID->quote($key));
		}
	}
	
	### ---
	### DESC Constractor
	### ---
	sub new_desc {
		
		my ($class, $key) = @_;
		if ($key) {
			return $class->SUPER::new(SQL::OOP::ID->quote($key). " DESC");
		}
	}

1;

__END__

=head1 NAME

SQL::OOP::Select

=head1 SYNOPSIS

    my $where = SQL::OOP::Where->new();
    my $select = SQL::OOP::Select->new();
    
    # set clause by plain text
    $select->set(
        $select->ARG_FIELDS => '*',
        $select->ARG_FROM   => 'some_table',
        $select->ARG_WHERE  => q("some_filed" > 5)
    );

    # retset clauses using objects
    my $where = SQL::OOP::Where->new();
    $select->set(
        $select->ARG_FIELDS => SQL::OOP::ID->new('some_field'),
        $select->ARG_FROM   => SQL::OOP::ID->new('some_table'),
        $select->ARG_WHERE  => $where->cmp('=', "some_fileld", 'value')
    );
	
	# clause can treats subs so that temporary variables don't mess around
    $select->set(
        $select->ARG_FIELDS => '*',
        $select->ARG_FROM   => 'some_table',
        $select->ARG_WHERE  => sub {
            my $where = SQL::OOP::Where->new();
            return $where->cmp('=', "some_fileld", 'value');
        }
    );
    
    # SQL::OOP::Select can be part of any SQL::OOP sub classes
    my $where = SQL::OOP::Where->new();
    $where->cmp_nested('=', q{some_field}, $select); # some_filed = (SELECT ..)
    
    my $sql  = $select->to_string;
    my @bind = $select->bind;

=head1 DESCRIPTION

SQL::OOP::Select class represents Select commands. This module also contains
SQL::OOP::Order class which represents ORDER BY clause.

=head1 SQL::OOP::Select METHODS

=head2 new

=head2 set

=head2 to_string

=head2 bind

=head1 SQL::OOP::Order METHODS

=head2 abstract

=head2 new_desc

=head2 new_asc

=head2 append_asc

=head2 append_desc

=head1 CONSTANTS

=head2 ARG_FIELDS

argument key for FIELDS(=1)

=head2 ARG_FROM

argument key for FROM clause(=2)

=head2 ARG_WHERE

argument key for WHERE clause(=3)

=head2 ARG_GROUPBY

argument key for GROUP BY clause(=4)

=head2 ARG_ORDERBY

argument key for ORDER BY clause(=5)

=head2 ARG_LIMIT

argument key for LIMIT clause(=6)

=head2 ARG_OFFSET

argument key for OFFSET clause(=7)

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
