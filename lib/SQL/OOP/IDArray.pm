package SQL::OOP::IDArray;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use SQL::OOP::ID;
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
    @array = @{$array[0]} if (ref $array[0] && ref $array[0] eq 'ARRAY');
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
    return '('. $obj->to_string. ')' if ($obj->isa('SQL::OOP::Command'));
    return $obj->to_string;
}

1;

__END__

=head1 NAME

SQL::OOP::IDArray - ID arrays for SQL

=head1 SYNOPSIS
    
    my $sql = SQL::OOP->new;
    my $field1 = $sql->id(@path_to_field); # e.g. "tbl"."col1"
    my $field2 = $sql->id(@path_to_table); # e.g. "tbl"."col2"
    my $fields = SQL::OOP::IDArray->new($field1, $field2);
    $fields->to_string # e.g. "tbl"."col1", "tbl"."col2"

=head1 DESCRIPTION

This module provides a class SQL::OOP::IDArray which represents ID array.

=head1 METHODS

This class represents ID arrays such as field lists in SELECT or table lists
in FROM clause. This class inherits SQL::OOP::Array class.

=head2 SQL::OOP::IDArray->new(@ids)

    my $id_list = SQL::OOP::IDArray->new('tbl1', 'tbl2', 'tbl3');
    
    $id_list->to_string; # "tbl1", "tbl2", "tbl3"    

=head2 SQL::OOP::IDArray->new(@id_objects)

Here is some examples.
    
    my $sql = SQL::OOP->new;
    my $id_obj1 = $sql->id('public', 'tbl1');
    my $id_obj2 = $sql->id('public', 'tbl2');
    my $id_obj3 = $sql->id('public', 'tbl3');
    
    my $id_list = SQL::OOP::IDArray->new($id_obj1, $id_obj2, $id_obj3);
    
    $id_list->to_string; # "public"."tbl1", "public"."tbl2", "public"."tbl3"

=head2 $instance->append

Appends elements into existing instance.

=head2 fix_element_in_list_context

Finalizing method on Stringify. For internal use. This is internally called by
generate method to parenthesizes the SQL on list context.

=head1 SEE ALSO

=cut
