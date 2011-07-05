### ---
### Class for dot-chained Identifier ex) "public"."table"."colmun1"
### ---
package SQL::OOP::ID;
use strict;
use warnings;
use base qw(SQL::OOP::Array);
    
    ### ---
    ### Constructor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        return $class->SUPER::new(@array)->set_sepa('.');
    }
    
    ### ---
    ### Append ID
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        for my $elem (@array) {
            if ($elem) {
                push(@{$self->{array}}, SQL::OOP::ID::Parts->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### "field AS foo" syntax
    ### ---
    sub as {
        
        my ($self, $as) = (@_);
        $self->{as} = $as;
        return $self;
    }
    
    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        my @array = map {$_->to_string} @{$self->{array}};
        $self->{gen} = join($self->{sepa}, grep {$_} @array);

        if ($self->{as}) {
            $self->{gen} .= ' AS '. $self->quote($self->{as});
        }
        
        return $self;
    }

### ---
### Class for Identifier such as table, field schema
### ---
package SQL::OOP::ID::Parts;
use strict;
use warnings;
use base qw(SQL::OOP::Base);
    
    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        $self->SUPER::generate(@_);
        $self->{gen} = $self->quote($self->{gen});
    }

### ---
### Class for array of identifier ex) "tbl1"."col1", "tbl1"."col2"...
### ---
package SQL::OOP::IDArray;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP::Array);
    
    ### ---
    ### Constructor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        my $self = $class->SUPER::new(@array)->set_sepa(', ');
    }
    
    ### ---
    ### Append ID
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        foreach my $elem (@array) {
            if (blessed($elem) && $elem->isa('SQL::OOP::Base')) {
                push(@{$self->{array}}, $elem);
            } elsif ($elem) {
                push(@{$self->{array}}, SQL::OOP::ID->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### parenthisize sub query 
    ### ---
    sub fix_element_in_list_context {
        
        my ($self, $obj) = @_;
        if ($obj->isa('SQL::OOP::Command')) {
            return '('. $obj->to_string. ')';
        }
        return $obj->to_string;
    }

1;

__END__

=head1 NAME

SQL::OOP::ID - IDs for SQL

=head1 SYNOPSIS
    
    ### field
    my $field = SQL::OOP::ID->new(@path_to_field);
    $field->to_string # e.g. "tbl"."col"
    
    ### from
    my $from = SQL::OOP::ID->new(@path_to_table);
    $from->to_string # e.g. "schema"."tbl"
    
    ### IDArray
    my $fields = SQL::OOP::IDArray->new($field1, $field2);
    $fields->to_string # e.g. "schema"."tbl1", "schema"."tbl2"

=head1 DESCRIPTION

SQL::OOP::ID class represents IDs for such as table, schema fields. This module
also provides a class SQL::OOP::IDArray which represents ID array.

=head1 SQL::OOP::ID CLASS

This class represents IDs such as table names, schema, field names. This class
inherits SQL::OOP::Array class.

=head2 SQL::OOP::ID->new(@ids)

=head2 $instance->as($str)

Here is some examples.
    
    my $id_obj = SQL::OOP::ID->new('public', 'tbl1'); 
    $id_obj->to_string; # "public"."tbl1"
    
    $id_obj->as('TMP');
    $id_obj->to_string; # "public"."tbl1" AS TMP

=head1 SQL::OOP::IDArray CLASS

This class represents ID arrays such as field lists in SELECT or table lists
in FROM clause. This class inherits SQL::OOP::Array class.

=head2 SQL::OOP::IDArray->new(@ids)

    my $id_list = SQL::OOP::IDArray->new('tbl1', 'tbl2', 'tbl3');
    
    $id_list->to_string; # "tbl1", "tbl2", "tbl3"    

=head2 SQL::OOP::IDArray->new(@id_objects)

Here is some examples.
    
    my $id_obj1 = SQL::OOP::ID->new('public', 'tbl1');
    my $id_obj2 = SQL::OOP::ID->new('public', 'tbl2');
    my $id_obj3 = SQL::OOP::ID->new('public', 'tbl3');
    
    my $id_list = SQL::OOP::IDArray->new($id_obj1, $id_obj2, $id_obj3);
    
    $id_list->to_string; # "public"."tbl1", "public"."tbl2", "public"."tbl3"

=head1 SQL::OOP::ID::Parts CLASS

This class is for internal use.

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
