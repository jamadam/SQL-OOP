package SQL::OOP::Update;
use strict;
use warnings;
use SQL::OOP::Base;
use SQL::OOP::Where;
use SQL::OOP::Dataset;
use base qw(SQL::OOP::Command);

sub ARG_TABLE()     {'table'} ## no critic
sub ARG_DATASET()   {'dataset'} ## no critic
sub ARG_FROM()      {'from'} ## no critic
sub ARG_WHERE()     {'where'} ## no critic

### ---
### Get Names of set arguments in array ref
### ---
sub KEYS {
    return [qw(table dataset from where)];
}

### ---
### Get prefixes for each clause in hash ref
### ---
sub PREFIXES {
    return {
        table     => 'UPDATE',
        dataset   => 'SET',
        from      => 'FROM',
        where     => 'WHERE',
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
### Get SQL snippet
### ---
sub to_string {
    my ($self) = @_;
    local $SQL::OOP::Base::quote_char = $self->quote_char;
    $self->{array}->[1]->generate(SQL::OOP::Dataset->MODE_UPDATE);
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

SQL::OOP::Update

=head1 SYNOPSIS

    my $sql = SQL::OOP->new;
    my $update = SQL::OOP::Update->new;

    # set clause by plain text
    $update->set(
        table      => 'some_table',
        dataset    => 'a = b, c = d',
        where      => 'a = c',
    );
    
    # reset clauses using objects
    $update->set(
        table      => $sql->id('some_table'),
        dataset    => $sql->dataset(@data),
        where      => $sql->where->cmp('=', "some_fileld", 'value')
    );
    my $sql  = $update->to_string;
    my @bind = $update->bind;

=head1 DESCRIPTION

SQL::OOP::Select class represents Select commands.

=head1 SQL::OOP::Update CLASS

=head2 SQL::OOP::Update->new(%clause)

Constructor. It takes arguments in hash. It accepts following hash keys.
    
    table
    dataset
    from
    where

=head2 $instance->set(%clause)

This method resets the clause data. It takes same argument as constructor.

=head2 $instance->to_string

=head2 $instance->bind

=head1 CONSTANTS

=head2 KEYS

=head2 PREFIXES

=head2 ARG_TABLE

argument key for TABLE(='table')

=head2 ARG_DATASET

argument key for DATASET(='dataset')

=head2 ARG_FROM

argument key for FROM clause(='from')

=head2 ARG_WHERE

argument key for WHERE clause(='where')

=head1 SEE ALSO

=cut
