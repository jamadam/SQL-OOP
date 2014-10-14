use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;
use SQL::OOP::Join;

my $sql = SQL::OOP->new;

{
    
    my $expected = <<EOF;
SELECT
    hoge
FROM
    (table1 LEFT JOIN table2 ON "a" = "b")
WHERE
    a
EOF
    
    my $select = $sql->select(
        fields => 'hoge',
        from   => $sql->join(
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

done_testing();
