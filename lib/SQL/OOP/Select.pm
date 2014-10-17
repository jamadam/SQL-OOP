package SQL::OOP::Select;
use strict;
use warnings;
use SQL::OOP::Base;
use SQL::OOP::Where;
use SQL::OOP::Order;
use base qw(SQL::OOP::Command);

sub ARG_FIELDS()    {'fields'} ## no critic
sub ARG_FROM()      {'from'} ## no critic
sub ARG_WHERE()     {'where'} ## no critic
sub ARG_GROUPBY()   {'groupby'} ## no critic
sub ARG_ORDERBY()   {'orderby'} ## no critic
sub ARG_LIMIT()     {'limit'} ## no critic
sub ARG_OFFSET()    {'offset'} ## no critic

### ---
### Get Names of set arguments in array ref
### ---
sub KEYS {
    return
    [qw(fields from where groupby orderby limit offset)];
}

### ---
### Get prefixes for each clause in hash ref
### ---
sub PREFIXES {
    return {
        fields    => 'SELECT',
        from      => 'FROM',
        where     => 'WHERE',
        groupby   => 'GROUP BY',
        orderby   => 'ORDER BY',
        limit     => 'LIMIT',
        offset    => 'OFFSET',
    }
}

### ---
### Constructor
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
### "field AS foo" syntax
### ---
sub as {
    my ($self, $as) = (@_);
    $self->{as} = $as;
    return $self;
}

sub generate {
    my ($self) = @_;
    $self->SUPER::generate;
    $self->{gen} =
        '('. $self->{gen}. ') '. $self->quote($self->{as}) if ($self->{as})
}

### ---
### Get SQL snippet
### ---
sub to_string {
    my $self = shift;
    local $SQL::OOP::Base::quote_char = $self->quote_char;
    return $self->SUPER::to_string(@_);
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

SQL::OOP::Select

=head1 SYNOPSIS

    my $where = SQL::OOP::Where->new();
    my $select = SQL::OOP::Select->new();
    
    # set clause by plain text
    $select->set(
        fields => '*',
        from   => 'some_table',
        where  => q("some_filed" > 5)
        groupby   => 'some_field',
        orderby   => 'some_field ASC',
        limit     => '10',
        offset    => '2',
    );

    # reset clauses using objects
    my $where = SQL::OOP::Where->new();
    $select->set(
        fields => SQL::OOP::ID->new('some_field'),
        from   => SQL::OOP::ID->new('some_table'),
        where  => $where->cmp('=', "some_fileld", 'value')
        orderby => SQL::OOP::Order->new('a', 'b'),
    );
    
    # clause can treats subs so that temporary variables don't mess around
    $select->set(
        fields => '*',
        from   => 'some_table',
        where  => sub {
            my $where = SQL::OOP::Where->new();
            return $where->cmp('=', "some_fileld", 'value');
        }
    );
    
    # SQL::OOP::Select can be part of any SQL::OOP::Base sub classes
    my $select2 = SQL::OOP::Select->new();
    $select2->set(
        fields => q("col1", "col2"),
        from   => $select,
    );
    
    my $where = SQL::OOP::Where->new();
    $where->cmp('=', q{some_field}, $select); # some_filed = (SELECT ..)
    
    my $sql  = $select->to_string;
    my @bind = $select->bind;

=head1 DESCRIPTION

SQL::OOP::Select class represents Select commands. 

=head2 SQL::OOP::Select->new(%clause)

Constructor. It takes arguments in hash. It accepts following hash keys.
    
    fields
    from
    where
    groupby
    orderby
    limit
    offset

=head2 $instance->set(%clause)

This method resets the clause data. It takes same argument as
SQL::OOP::Select->new().

=head2 $instance->to_string

Get SQL snippet in string

=head2 $instance->bind

Get binded values in array

=head1 CONSTANTS

=head2 KEYS

=head2 PREFIXES

=head2 ARG_FIELDS

argument key for FIELDS(='fields')

=head2 ARG_FROM

argument key for FROM clause(='from')

=head2 ARG_WHERE

argument key for WHERE clause(='where')

=head2 ARG_GROUPBY

argument key for GROUP BY clause(='groupby')

=head2 ARG_ORDERBY

argument key for ORDER BY clause(='orderby')

=head2 ARG_LIMIT

argument key for LIMIT clause(='limit')

=head2 ARG_OFFSET

argument key for OFFSET clause(='offset')

=head1 EXAMPLE

Here is a comprehensive example for SELECT. You also can find some examples in
test scripts.

    my $select = SQL::OOP::Select->new();
    $select->set(
        fields => '*',
        from   => 'table',
        where  => sub {
            my $where = SQL::OOP::Where->new;
            return $where->and(
                $where->cmp('=', 'a', 1),
                $where->cmp('=', 'b', 1),
            )
        },
    );

=head1 SEE ALSO

=cut
