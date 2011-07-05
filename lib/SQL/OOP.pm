package SQL::OOP;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(Class::Data::Inheritable);
use 5.005;
our $VERSION = '0.09';

1;
__END__

=head1 NAME

SQL::OOP - SQL Generator base class

=head1 SYNOPSIS
    
    my $sql = SQL::OOP->new;
    
    ### Returns SQL::Abstract style values that can be thrown at DBI methods.
    my $sql  = $select->to_string;
    my @bind = $select->bind;
    
    ### field
    my $field_obj = SQL::OOP::ID->new(@path_to_field); # e.g. "tbl"."col"
    
    ### from
    my $from_obj = SQL::OOP::ID->new(@path_to_table); # e.g. "schema"."tbl"

=head1 DESCRIPTION

This module provides you an object oriented interface to generate SQL
statements. This doesn't require any complex syntaxed hash structure. All you
have to do is to call well-readable OOP methods.

SQL::OOP distibution includes some modules. This is the base class of them.
    
    SQL::OOP [abstract]
        SQL::OOP::Array [abstract]
            SQL::OOP::ID
                SQL::OOP::IDArray
            SQL::OOP::Order
            SQL::OOP::Dataset
            SQL::OOP::Command [abstract]
                SQL::OOP::Select
                SQL::OOP::Insert
                SQL::OOP::Update
                SQL::OOP::Delete
            SQL::OOP::Order
    SQL::OOP::Where [factory]

Any instace returned by each class are capable of to_string() and bind(). These
methods returns similar values as SQL::Abstract. 

=head1 SQL::OOP CLASS

This class represents SQLs or SQL snippets.

=head2 SQL::OOP->new($str, $array_ref)
    
Constractor. It takes String and array ref.

    my $sql = SQL::OOP->new('a = ? and b = ?', [10,20]);

=head2 SQL::OOP->quote_char($quote_char)

=head2 SQL::OOP->escape_code_ref($code_ref)

=head2 $instance->to_string()

This method returns the SQL string.

    $sql->to_string # 'a = ? and b = ?'

=head2 $instance->to_string_embeded() [EXPERIMENTAL]

This method returns the SQL string with binded values enbeded. This method aimed
at use of debugging.

    $sql->to_string_embeded # a = 'value' and b = 'value'

=head2 $instance->bind()

This method returns binded values in array.

    $sql->bind      # [10,20]

=head2 $instance->generate()

=head2 SQL::OOP->quote()

=head1 SQL::OOP::Array CLASS

This is an abstract class that extends SQL::OOP

=head2 $instance->append(@elements)

This method appends elements to the instance and returns $self;

=head1 SQL::OOP::ID CLASS

This class represents IDs such as table names, field names.

=head2 SQL::OOP::ID->new(@ids)

=head2 $instance->as($str)

Here is some examples.
    
    my $id_obj = SQL::OOP::ID->new('public', 'tbl1'); 
    $id_obj->to_string; # "public"."tbl1"
    
    $id_obj->as('TMP');
    $id_obj->to_string; # "public"."tbl1" AS TMP

=head1 SQL::OOP::IDArray CLASS

This class represents ID arrays such as field lists in SELECT or table lists
in FROM clause.

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
