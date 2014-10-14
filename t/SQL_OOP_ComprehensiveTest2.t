package SQL_OOP_CpmprehensiveTest2;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub basic_test: Test(1) {
    
    my $expected = compress_sql(<<EXPECTED);
SELECT
    *
FROM
    table
WHERE
    "a" = ? AND "b" = ?
EXPECTED

    ### The following blocks are expected to generate same SQL
    {
        my $select = $sql->select;
        $select->set(
            fields => '*',
            from   => 'table',
            where  => q{"a" = ? AND "b" = ?},
        );
        
        is($select->to_string, $expected, 'All literaly');
    }
}

sub compress_sql {
    
    my $sql = shift;
    $sql =~ s/[\s\r\n]+/ /gs;
    $sql =~ s/[\s\r\n]+$//gs;
    $sql =~ s/\(\s/\(/gs;
    $sql =~ s/\s\)/\)/gs;
    return $sql;
}
