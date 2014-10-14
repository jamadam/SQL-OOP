use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::IDArray;
use SQL::OOP::Select;

my $sql = SQL::OOP->new;

{
    my $select = $sql->select;
    my $fields = $sql->id_array(qw(a b c));
    my $sql = $fields->to_string;
    is($sql, qq{"a", "b", "c"});
}

{
    my $b = $sql->base('a,b,c');
    is($b->to_string, 'a,b,c', 'basic test for to_string');
}

{
    my $a = $sql->array('', '', ('a',undef,'c'))->set_sepa(', ');
    is($a->to_string, 'a, c', 'array include undef test');
}

{
    my $a = $sql->array('', '', qw(a b c))->set_sepa(', ');
    is($a->to_string, 'a, b, c', 'basic array test for bind');
}

{
    my $and = $sql->where->and(
        'a',
        'b',
    );
    is($and->to_string, 'a AND b', 'where initial');
    $and->append('c');
    is($and->to_string, 'a AND b AND c', 'where append');
    $and->append($sql->where->cmp('=', 'd', 'e'));
    is($and->to_string, 'a AND b AND c AND "d" = ?', 'where append obj');
}

{
    my $cmp = $sql->where->cmp('=', 'column1', 'value');
    my $and = $sql->where->and($cmp, $cmp);
    my $str = $and->to_string;
    is($str, qq{"column1" = ? AND "column1" = ?}, 'cmp and cmp');
}

{
    my $cmp = $sql->where->cmp('=', 'column1', 'value');
    my $str = $cmp->to_string;
    my @bind = $cmp->bind;
    is($str, qq{"column1" = ?}, 'to_string');
    is(shift @bind, qw(value), 'bind');
    is(shift @bind, undef, 'no more bind');
    
    my $str2 = $cmp->to_string('WHERE');
    is($str2, qq{WHERE "column1" = ?}, 'prefixed');
}

### Pertial adoption
{
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
    {
        my $select = $sql->select;
        $select->set(
            fields     => '*',
            from       => 'table',
            where      => q{"a" = ? AND "b" = ?},
            orderby    => undef,
            limit      => '',
        );
        
        is($select->to_string, $expected, 'Some clause maybe empty');
    }
    {
        my $select = $sql->select;
        $select->set(
            fields => '*',
            from   => 'table',
            where  => $sql->base(q{"a" = ? AND "b" = ?}, [1, 2]),
        );
        
        is($select->to_string, $expected, 'Literaly but need to bind');
        my @bind = $select->bind;
        is(shift @bind, '1', 'Literaly but need to bind[sql]');
        is(shift @bind, '2', 'Literaly but need to bind[bind]');
        is(shift @bind, undef, 'Literaly but need to bind[no more bind]');
    }
    {
        my $select = $sql->select;
        $select->set(
            fields => '*',
            from   => 'table',
            where  => $sql->where->and(
                $sql->where->cmp('=', 'a', 1),
                $sql->where->cmp('=', 'b', 1),
            ),
        );
        
        is($select->to_string, $expected, 'Use SQL::OOP::WHERE');
    }
    {
        my $select = $sql->select;
        $select->set(
            fields => '*',
            from   => 'table',
            where  => sub {
                return $sql->where->and(
                    $sql->where->cmp('=', 'a', 1),
                    $sql->where->cmp('=', 'b', 1),
                )
            },
        );
        
        is($select->to_string, $expected, 'Use WHERE in sub');
    }
}

{
    my $expected = compress_sql(<<"EXPECTED");
SELECT
    "ky1", "ky2", *
FROM
    "tbl1", "tbl2", "tbl3"
WHERE
    "hoge1" >= ?
    AND
    "hoge2" = ?
    AND
    (
        "hoge3" = ?
        OR
        "hoge4" = ?
        OR
        "price" BETWEEN ? AND ?
        OR
        "vprice" IS NULL
        OR
        a = b
        OR
        a = b
        OR
        c = ? ?
        OR
        "price"
        BETWEEN ? AND ?
    )
ORDER BY
    "hoge1" DESC, "hoge2"
LIMIT
    11315
OFFSET
    1
EXPECTED
    
    {
        my $select = $sql->select;
        $select->set(
            fields => $sql->base(q{"ky1", "ky2", *}),
            from   => q("tbl1", "tbl2", "tbl3"),
            where  => sub {
                return $sql->where->and(
                    $sql->where->cmp('>=', 'hoge1', 'hoge1'),
                    $sql->where->cmp('=', 'hoge2', 'hoge2'),
                    $sql->where->or(
                        $sql->where->cmp('=', 'hoge3', 'hoge3'),
                        $sql->where->cmp('=', 'hoge4', 'hoge4'),
                        $sql->where->between('price', 10, 20),
                        $sql->where->is_null('vprice'),
                        $sql->base('a = b'),
                        'a = b',
                        $sql->base('c = ? ?', ['code1', 'code2']),
                        $sql->where->between('price', 10, 20),
                    ),
                    $sql->where->or(
                        $sql->where->cmp('=', 'hoge3', undef),
                        $sql->where->cmp('=', 'hoge4', undef),
                    ),
                )
            },
            orderby => sub {
                my $order = $sql->order;
                foreach my $rec_ref (@{[['hoge1', 1],['hoge2']]}) {
                    if ($rec_ref->[1]) {
                        $order->append_desc($rec_ref->[0]);
                    } else {
                        $order->append_asc($rec_ref->[0]);
                    }
                }
                return $order;
            },
            limit  => 11315,
            offset => 1,
        );
        
        is($select->to_string, $expected, 'complex to_string');
        my @bind = $select->bind;
        is(scalar @bind, 10, 'complex bind size');
        is(shift @bind, qw(hoge1), 'complex bind');
        is(shift @bind, qw(hoge2), 'complex bind');
        is(shift @bind, qw(hoge3), 'complex bind');
        is(shift @bind, qw(hoge4), 'complex bind');
        is(shift @bind, qw(10), 'complex bind');
        is(shift @bind, qw(20), 'complex bind');
        is(shift @bind, qw(code1), 'complex bind');
        is(shift @bind, qw(code2), 'complex bind');
        is(shift @bind, qw(10), 'complex bind');
        is(shift @bind, qw(20), 'complex bind');
        is(shift @bind, undef, 'complex bind');
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

done_testing();
