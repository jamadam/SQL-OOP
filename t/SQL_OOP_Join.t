package SQL_OOP_UpdateTest;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;
use SQL::OOP::Join;

__PACKAGE__->runtests;

sub join : Test(1) {
    
    my $expected = <<EOF;
SELECT
    hoge
FROM
    (table1 LEFT JOIN table2 ON "a" = "b")
WHERE
    a
EOF
    
    my $select = SQL::OOP::Select->new;
    $select->set(
        fields => 'hoge',
        from   => SQL::OOP::Join->new(
            direction   => 'LEFT',
            table1      => 'table1',
            table2      => 'table2',
            on          => '"a" = "b"',
        ),
        where  => 'a',
    );
    
    is($select->to_string, compress_sql($expected));
}

sub compress_sql {
    
    my $sql = shift;
    $sql =~ s/[\s\r\n]+/ /gs;
    $sql =~ s/[\s\r\n]+$//gs;
    $sql =~ s/\(\s/\(/gs;
    $sql =~ s/\s\)/\)/gs;
    return $sql;
}
