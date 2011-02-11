package SQL::OOP::Select;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use base qw(SQL::OOP::Command);

    sub ARG_FIELDS()    {1} ## no critic
    sub ARG_FROM()      {2} ## no critic
    sub ARG_WHERE()     {3} ## no critic
    sub ARG_GROUPBY()   {4} ## no critic
    sub ARG_ORDERBY()   {5} ## no critic
    sub ARG_LIMIT()     {6} ## no critic
    sub ARG_OFFSET()    {7} ## no critic
    
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
            ARG_FIELDS()    => 'SELECT',
            ARG_FROM()      => 'FROM',
            ARG_WHERE()     => 'WHERE',
            ARG_GROUPBY()   => 'GROUP BY',
            ARG_ORDERBY()   => 'ORDER BY',
            ARG_LIMIT()     => 'LIMIT',
            ARG_OFFSET()    => 'OFFSET',
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
    
    ### ---
    ### Constract ORER BY clause by array
    ### ---
    sub abstract {
        
        my ($class, $array_ref) = @_;
        my $self = $class->SUPER::new()->set_sepa(', ');
        foreach my $rec_ref (@{$array_ref}) {
            if (ref $rec_ref) {
                if ($rec_ref->[1]) {
                    $self->append_desc($rec_ref->[0]);
                } else {
                    $self->append_asc($rec_ref->[0]);
                }
            } else {
                $self->append_asc($rec_ref);
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
        $select->ARG_GROUPBY   => 'some_field',
        $select->ARG_ORDERBY   => 'some_field ASC',
        $select->ARG_LIMIT     => '10',
        $select->ARG_OFFSET    => '2',
    );

    # reset clauses using objects
    my $where = SQL::OOP::Where->new();
    $select->set(
        $select->ARG_FIELDS => SQL::OOP::ID->new('some_field'),
        $select->ARG_FROM   => SQL::OOP::ID->new('some_table'),
        $select->ARG_WHERE  => $where->cmp('=', "some_fileld", 'value')
        $select->ARG_ORDERBY=> SQL::OOP::Order->new('a', 'b'),
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
    my $select2 = SQL::OOP::Select->new();
    $select2->set(
        $select2->ARG_FIELDS => q("col1", "col2"),
        $select2->ARG_FROM   => $select,
    );
    
    my $where = SQL::OOP::Where->new();
    $where->cmp_nested('=', q{some_field}, $select); # some_filed = (SELECT ..)
    
    my $sql  = $select->to_string;
    my @bind = $select->bind;

=head1 DESCRIPTION

SQL::OOP::Select class represents Select commands. This module also contains
SQL::OOP::Order class which represents ORDER BY clause.

=head1 SQL::OOP::Select CLASS

This class represents SQL SELECT command

=head2 SQL::OOP::Select->new(%clause)

Constractor. It takes argsuments in hash. The Hash keys are provided by
following methods. They can call as either class or instance method.
    
    ARG_FIELDS
    ARG_FROM
    ARG_WHERE
    ARG_GROUPBY
    ARG_ORDERBY
    ARG_LIMIT
    ARG_OFFSET

=head2 $instance->set(%clause)

This method resets the clause data. It takes same argument as
SQL::OOP::Select->new().

=head2 $instance->to_string

Get SQL snippet in string

=head2 $instance->bind

Get binded values in array

=head1 SQL::OOP::Order CLASS

This class represents ORDER clause.

=head2 SQL::OOP::Order->new(@array);

Constractor.

=head2 $instance->append_asc($key);

=head2 $instance->append_desc($key);
    
    my $order = SQL::OOP::Order->new;
    $order->append_asc('age');
    $order->append_desc('address');
    $order->to_string; # "age", "address" DESC

=head2 SQL::OOP::Order->new_asc();

Constractor for ASC expression. This returns SQL::OOP::Order::Expression
instance which can be thrown at SQL::OOP::Order class constractor or instances.

=head2 SQL::OOP::Order->new_desc();

Constractor for DESC expression. This returns SQL::OOP::Order::Expression
instance which can be thrown at SQL::OOP::Order class constractor or instances.

=head2 abstract

Constract by array ref

    SQL::OOP::Order->abstract([['col1', 1], 'col2']);   # "col1" DESC, "col2"
    SQL::OOP::Order->abstract([['col1', 1], ['col2']]); # "col1" DESC, "col2"

=head2 append_asc

Append ASC entry

=head2 append_desc

Append DESC entry

=head1 CONSTANTS

=head2 KEYS

=head2 PREFIXES

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

=head1 EXAMPLE

Here is a complehensive example for SELECT. You also can find some examples in
test scripts.

    my $select = SQL::OOP::Select->new();
    $select->set(
        $select->ARG_FIELDS => '*',
        $select->ARG_FROM   => 'table',
        $select->ARG_WHERE  => sub {
            my $where = SQL::OOP::Where->new;
            return $where->and(
                $where->cmp('=', 'a', 1),
                $where->cmp('=', 'b', 1),
            )
        },
    );

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
