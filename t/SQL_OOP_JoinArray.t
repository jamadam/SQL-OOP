package SQL_OOP_UpdateTest;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub join : Test(1) {
    
    my $expected = <<EOF;
SELECT
    hoge
FROM
    table1
    LEFT JOIN
        table2
        ON "a" = "b"
    INNER JOIN
        table4
        ON "a" = "b"
WHERE a
EOF
    
    my $select = $sql->select(
        fields => 'hoge',
        from   => $sql->join_array(
            $sql->join(
                direction   => 'LEFT',
                table1      => 'table1',
                table2      => 'table2',
                on          => '"a" = "b"',
            ),
            $sql->join(
                direction   => 'INNER',
                table2      => 'table4',
                on          => '"a" = "b"',
            ),
        ),
        where  => 'a',
    );
    is($select->to_string, compress_sql($expected));
}

sub join_nested : Test(1) {
    
    my $expected = <<EOF;
SELECT
    hoge
FROM
    table1
    LEFT JOIN
        table2
        ON "a" = "b"
    INNER JOIN
        (
            SELECT
                hoge
            FROM
                table4
            WHERE
                a
        )
        ON "a" = "b"
WHERE a
EOF
    
    my $select = $sql->select(
        fields => 'hoge',
        from   => $sql->join_array(
            $sql->join(
                direction   => 'LEFT',
                table1      => 'table1',
                table2      => 'table2',
                on          => '"a" = "b"',
            ),
            $sql->join(
                direction => 'INNER',
                table2 => $sql->select(
                    fields => 'hoge',
                    from => 'table4',
                    where => 'a',
                ),
                on => '"a" = "b"',
            ),
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
