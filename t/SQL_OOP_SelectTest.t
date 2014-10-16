use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;

my $sql = SQL::OOP->new;

{
    my $select = $sql->select;
    $select->set(
        where   => sub {
            $sql->array('a', 'b', undef, 'c')->set_sepa(', ')
        }
    );
    is($select->to_string, 'WHERE a, b, c');
    is(ref $select->retrieve('where'), 'SQL::OOP::Array');
}

{
    my $select = $sql->select;
    $select->set(
        fields => 'key1',
        from   => 'table1',
    );
    
    is($select->to_string, q(SELECT key1 FROM table1));
    
    ### append clause
    $select->set(
        where  => 'some cond',
    );
    
    is($select->to_string, q(SELECT key1 FROM table1 WHERE some cond));
    is(ref $select->retrieve('fields'), 'SQL::OOP::Base');
    is(ref $select->retrieve('from'), 'SQL::OOP::Base');
    is(ref $select->retrieve('where'), 'SQL::OOP::Base');
}

{
    my $select = $sql->select;
    $select->set(
        fields => 'key1',
        from   => 'table1',
    );
    $select->set(
        where  => $sql->where->cmp('=', 'a', 'b'),
    );
    
    is($select->to_string, q(SELECT key1 FROM table1 WHERE "a" = ?));
    my @bind = $select->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'b');
}

{
    my $array = $sql->array('a', 'b', undef, 'c')->set_sepa(', ');
    is($array->to_string, 'a, b, c');
}

{
    my $select = $sql->select;
    $select->set(
        where => $sql->where->cmp('=', 'col1', $sql->id('col2'))
    );
    is($select->to_string, 'WHERE "col1" = ("col2")');
}

{
    my $base = $sql->base('col2');
    my $a = $sql->where->cmp('=', 'col1', $base);
    my $select = $sql->select;
    $select->set(
        fields => '*',
        where  => $a,
    );
    is($select->to_string, 'SELECT * WHERE "col1" = col2');
}

{
    my $select = $sql->select;
    $select->set(
        fields => 'max(a) AS b',
        from   => 'tbl',
    );
    is($select->to_string, 'SELECT max(a) AS b FROM tbl');
}

{
    my $select = $sql->select;
    $select->set(
        fields => 'col1',
        from   => 'tbl',
        where   => 'test'
    );
    my $array = $sql->array('col1', $select)->set_sepa(' = ');
    is($array->to_string, q{col1 = (SELECT col1 FROM tbl WHERE test)});
}

{
    my $select = $sql->select;
    $select->set(
        fields    => '*',
        where     => $sql->where->cmp('=', 'col1', 'col2')
    );
    my $a = $sql->where->cmp('=', 'col1', $select);
    is($a->to_string, '"col1" = (SELECT * WHERE "col1" = ?)');
    my @bind = $a->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'col2');
}

{
    my $select1 = $sql->select;
    $select1->set(
        fields    => '*',
        where     => $sql->where->cmp('=', 'col1', 'col2')
    );
    my $a = $sql->where->cmp('=', 'col1', $select1);
    my $select2 = $sql->select;
    $select2->set(
        fields => '*',
        where  => $a,
    );
    is($select2->to_string, q{SELECT * WHERE "col1" = (SELECT * WHERE "col1" = ?)});
    my @bind = $select2->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'col2');
}

{
    my $select = $sql->select;
    $select->set(
        fields => '*',
        where  => $sql->where->cmp('=', 'col1', sub {
            my $select = $sql->select;
            $select->set(
                fields  => '*',
                where   => 'test'
            );
        }),
    );
    
    is($select->to_string, q{SELECT * WHERE "col1" = (SELECT * WHERE test)});
}

{
    my $select = $sql->select;
    $select->set(
        fields => '*',
        where  => $sql->where->cmp('=', 'col1', sub {
            $sql->select(
                fields => '*',
                where => $sql->where->cmp('=', 'col1', 'col2')
            );
        }),
    );
    is($select->to_string, q{SELECT * WHERE "col1" = (SELECT * WHERE "col1" = ?)});
    my @bind = $select->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'col2');
}

{
    my $expected = compress_sql(<<EOF);
SELECT
    *
FROM
    "tbl" A
WHERE
    "A"."col1" = (
        SELECT
            "col1"
        FROM
            "tbl2" AS "B"
        WHERE
            "A"."id" = ?
    )
EOF
    
    my $select = $sql->select;
    $select->set(
        fields => '*',
        from   => q("tbl" A),
        where  => sub {
            my $select2 = $sql->select->set(
                fields => $sql->id('col1'),
                from   => $sql->id('tbl2')->as('B'),
                where  =>
                    $sql->where->cmp('=', $sql->id('A', 'id'), 'col2')
            );
            return $sql->where->cmp('=', $sql->id('A', 'col1'), $select2);
        }
    );
    
    is($select->to_string, $expected);
    my @bind = $select->bind;
}

{
    
    my $expected = compress_sql(<<EOF);
SELECT
    *
FROM
    (
        SELECT
            "col1", "col2"
        FROM
            "table1"
    )
EOF
    
    my $select = $sql->select;
    my $select2 = $sql->select;
    
    $select2->set(
        fields => q("col1", "col2"),
        from   => q("table1"),
    );
    $select->set(
        fields => '*',
        from   => $select2,
    );
    
    is($select->to_string, $expected);
    my @bind = $select->bind;
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
