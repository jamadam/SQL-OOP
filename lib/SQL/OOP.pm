package SQL::OOP;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(Class::Data::Inheritable);
use SQL::OOP::Base;
use 5.005;
our $VERSION = '0.09';

    sub new {
        return SQL::OOP::Base->new(@_);
    }
    
    sub quote_char {
        return SQL::OOP::Base->quote_char(@_);
    }
    
    sub escape_code_ref {
        return SQL::OOP::Base->escape_code_ref(@_);
    }
    
1;
__END__

=head1 NAME

SQL::OOP - SQL Generator

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
statements. This doesn't require any complex syntactical hash structure. All you
have to do is to call well-readable OOP methods.

SQL::OOP distribution includes some modules. This is the base class of them.
    
    SQL::OOP::Base [abstract]
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

Any instance returned by each class are capable of to_string() and bind(). These
methods returns similar values as SQL::Abstract. 

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
