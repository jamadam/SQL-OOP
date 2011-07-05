### ---
### Array of SQL snippets
### ---
package SQL::OOP::Array;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP::Base);
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        my $self = bless {
            sepa    => ' ',
            gen     => undef,
            array   => undef,
        }, $class;
        
        return $self->append(@array);
    }
    
    ### ---
    ### Set separator for join array
    ### ---
    sub set_sepa {
        
        my ($self, $sepa) = @_;
        $self->{sepa} = $sepa;
        return $self;
    }
    
    ### ---
    ### Append snippet
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        foreach my $elem (@array) {
            if ($elem) {
                push(@{$self->{array}}, SQL::OOP::Base->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        my @array = map {
            if ($_->to_string && (scalar @{$self->{array}}) >= 2) {
                $self->fix_element_in_list_context($_);
            } else {
                $_->to_string;
            }
        } @{$self->{array}};
        $self->{gen} = join($self->{sepa}, grep {$_} @array);
        
        return $self;
    }
    
    ### ---
    ### fix generated string in list context
    ### ---
    sub fix_element_in_list_context {
        
        my ($self, $obj) = @_;
        if ($obj->isa(__PACKAGE__)) {
            return '('. $obj->to_string. ')';
        }
        return $obj->to_string;
    }
    
    ### ---
    ### Get binded values in array
    ### ---
    sub bind {
        
        my $self = shift;
        my @out = map {
            my @a;
            if ($_) {
                @a = $_->bind;
            }
            @a;
        } @{$self->{array}};
        return @out if (wantarray);
        return scalar @out;
    }

1;

__END__

=head1 NAME

SQL::OOP::Array - An Abstract class for any combination of snippets

=head1 SYNOPSIS
    
    my $array = SQL::OOP::Array->new(@elements);
    my $sql  = $array->to_string;
    my @bind = $array->bind;

=head1 DESCRIPTION

This class represents array of SQL snippets.

=head1 METHODS

=head2 SQL::OOP::Array->new(@elements)

=head2 $instance->append(@elements)

This method appends elements to the instance and returns $self;

=head1 SEE ALSO

L<SQL::OOP::Order>
L<SQL::OOP::Dataset>
L<SQL::OOP::Command>
L<SQL::OOP::Select>
L<SQL::OOP::Insert>
L<SQL::OOP::Update>
L<SQL::OOP::Delete>
L<SQL::OOP::Where>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
