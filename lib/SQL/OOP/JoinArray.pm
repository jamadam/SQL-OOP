package SQL::OOP::JoinArray;
use strict;
use warnings;
use SQL::OOP::Base;
use base qw(SQL::OOP::Array);

### ---
### fix generated string in list context
### ---
sub fix_element_in_list_context {
    my ($self, $obj) = @_;
    return $obj->to_string;
}

1;

__END__

=head1 NAME

SQL::OOP::JoinArray [EXPERIMENTAL]

=head1 SYNOPSIS

    $from = SQL::OOP::JoinArray->new(
        $sql->join(
            direction   => 'LEFT',
            table1      => 'table1',
            table2      => 'table2',
            on          => 'table2.col = table1.col',
        ),
        $sql->join(
            direction   => 'INNER',
            table2      => 'table3',
            on          => 'table3.col = table2.col',
        ),
    );
    
    # table1 LEFT JOIN table2 ON table2.col = table1.col INNER JOIN table3 ON ...
    say $joins->to_string;
    
    $select->set(from => $from);

=head1 DESCRIPTION

Represents multiple join entries for FROM clause.

=head1 METHODS

=head2 SQL::OOP::JoinArray->new

Constructor.

=head2 $instance->fix_element_in_list_context;

Finalizing method on Stringify. For internal use.

=head1 SEE ALSO

=cut
