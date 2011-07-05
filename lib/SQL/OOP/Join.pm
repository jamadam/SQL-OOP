package SQL::OOP::Join;
use strict;
use warnings;
use SQL::OOP::Base;
use base qw(SQL::OOP::Command);

    sub ARG_DIRECTION()     {1} ## no critic
    sub ARG_TABLE1()        {2} ## no critic
    sub ARG_TABLE2()        {3} ## no critic
    sub ARG_ON()            {4} ## no critic
    
    sub ARG_DIRECTION_INNER()   {'INNER'} ## no critic
    sub ARG_DIRECTION_LEFT()    {'LEFT'} ## no critic
    sub ARG_DIRECTION_RIGHT()   {'RIGHT'} ## no critic
    
    ### ---
    ### Get Names of set arguments in array ref
    ### ---
    sub KEYS {
        
        return [ARG_TABLE1, ARG_DIRECTION, ARG_TABLE2, ARG_ON];
    }
    
    ### ---
    ### Get prefixes for each clause in hash ref
    ### ---
    sub PREFIXES {
        
        my $self= shift;
        return {
            ARG_TABLE1()        => '',
            ARG_DIRECTION()     => '',
            ARG_TABLE2()        => 'JOIN',
            ARG_ON()            => 'ON',
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

=head2 ARG_DIRECTION_INNER

=head2 ARG_DIRECTION_LEFT

=head2 ARG_DIRECTION_RIGHT

=head2 ARG_ON

=head2 ARG_TABLE1

=head2 ARG_TABLE2

=head2 KEYS

=head2 PREFIXES

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
