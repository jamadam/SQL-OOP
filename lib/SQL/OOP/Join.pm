package SQL::OOP::Join;
use strict;
use warnings;
use SQL::OOP::Base;
use base qw(SQL::OOP::Command);

sub ARG_DIRECTION()     {'direction'} ## no critic
sub ARG_TABLE1()        {'table1'} ## no critic
sub ARG_TABLE2()        {'table2'} ## no critic
sub ARG_ON()            {'on'} ## no critic

sub ARG_DIRECTION_INNER()   {'INNER'} ## no critic
sub ARG_DIRECTION_LEFT()    {'LEFT'} ## no critic
sub ARG_DIRECTION_RIGHT()   {'RIGHT'} ## no critic

### ---
### Get Names of set arguments in array ref
### ---
sub KEYS {
    return [qw(table1 direction table2 on)];
}

### ---
### Get prefixes for each clause in hash ref
### ---
sub PREFIXES {
    my $self= shift;
    return {
        table1        => '',
        direction     => '',
        table2        => 'JOIN',
        on            => 'ON',
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

SQL::OOP::Join [EXPERIMENTAL]

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 SQL::OOP::Join->new

=head2 $instance->bind

=head2 $instance->set

=head2 $instance->to_string

=head1 Constants

=head2 ARG_DIRECTION

(='direction')

=head2 ARG_DIRECTION_INNER

(='INNER')

=head2 ARG_DIRECTION_LEFT

(='LEFT')

=head2 ARG_DIRECTION_RIGHT

(='RIGHT')

=head2 ARG_ON

(='on')

=head2 ARG_TABLE1

(='table1')

=head2 ARG_TABLE2

(='table2')

=head2 KEYS

=head2 PREFIXES

=head1 SEE ALSO

=cut
