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

    my $select = SQL::OOP::Select->new();
    
    $select->set(
        $select->ARG_FIELDS => '*',
        $select->ARG_FROM   => SQL::OOP::ID->new('public', 'master'),
        $select->ARG_WHERE  => sub {
            my $where = SQL::OOP::Where->new;
            return $where->and(
                $where->cmp('=', 'a', 1),
                $where->cmp('=', 'b', 1),
            )
        },
        $select->GROUP_BY => 'field1',
        $select->ARG_LIMIT => 10,
    );

=head1 DESCRIPTION

SQL::OOP provides an object oriented interface for generating SQL statements.
This doesn't require any complex syntactical hash structure. All you have to do
is to call well-readable OOP methods.

SQL::OOP distribution includes some modules. The following indecates the
hierarchy of inheritance.
    
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
methods returns similar values as SQL::Abstract, which can be thrown at DBI
methods. 

Most class inherits SQL::OOP::Array which can contain array of SQL::OOP. This
means most instances can contain any others. This means that a SELECT instance
can be part of other SELECT command, for instance.

This is an example of WHERE clause.

    my $util = SQL::OOP::Where->new; ## for convenience
    
    my $cond1 = $util->cmp('<', 'price', '100');
    my $cond2 = $util->cmp('=', 'category', 'book');
    my $and = $util->and($cond1, $cond2);
    
    my $sql1 = $and->to_string # price < ? AND category = ?

$cond1 and $cond2 are SQL::OOP::Base instances. $and which is a SQL::OOP::Array
instance can contain $cond1 and $cond2.
    
    my $cond3 = $util->cmp('like', 'title', '%Perl%');
    my $or = $util->or($and, $cond3);
    
    my $sql2 = $and->to_string # (price < ? AND category = ?) OR title like ?

$or is a SQL::OOP::Array instance which can contain both SQL::OOP::Base and
SQL::OOP::Array.

=head1 METHODS

=head2 SQL::OOP->new

This is an alias for SQLL::OOP::Base->new

=head2 SQL::OOP->quote_char

This is an alias for SQLL::OOP::Base->quote_char

=head2 SQL::OOP->escape_code_ref

This is an alias for SQLL::OOP::Base->escape_code_ref

=head1 SEE ALSO

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
