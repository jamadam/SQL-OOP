package SQL_OOP_SelectTest;
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

sub array_include_undef2 : Test(1) {
    
    my $select = $sql->select;
    $select->set(
        where   => sub {
            $sql->array('a', 'b', undef, 'c')->set_sepa(', ')
        }
    );
    is($select->to_string, 'WHERE a, b, c');
}

sub set_clause_separately : Test(2) {
    
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
}

sub set_clause_separately_with_bind : Test(3) {
    
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

sub array_to_string : Test(1) {
    
    my $array = $sql->array('a', 'b', undef, 'c')->set_sepa(', ');
    is($array->to_string, 'a, b, c');
}

sub array_to_string3 : Test(1) {
    
    my $select = $sql->select;
    $select->set(
        where => $sql->where->cmp('=', 'col1', $sql->id('col2'))
    );
    is($select->to_string, 'WHERE "col1" = ("col2")');
}

sub array_to_string4 : Test(1) {
    
    my $base = $sql->base('col2');
    my $a = $sql->where->cmp('=', 'col1', $base);
    my $select = $sql->select;
    $select->set(
        fields => '*',
        where  => $a,
    );
    is($select->to_string, 'SELECT * WHERE "col1" = col2');
}

sub function_in_field : Test(1) {
    
    my $select = $sql->select;
    $select->set(
        fields => 'max(a) AS b',
        from   => 'tbl',
    );
    is($select->to_string, 'SELECT max(a) AS b FROM tbl');
}

sub select_part_of_other1 : Test(1) {
    
    my $select = $sql->select;
    $select->set(
        fields => 'col1',
        from   => 'tbl',
        where   => 'test'
    );
    my $array = $sql->array('col1', $select)->set_sepa(' = ');
    is($array->to_string, q{col1 = (SELECT col1 FROM tbl WHERE test)});
}

sub select_part_of_other2 : Test(3) {
    
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

sub cmp_nested_subquery2 : Test(3) {
    
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

sub subquery_in_where : Test(1) {
    
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

sub subquery_in_where2 : Test(3) {
    
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

sub subquery_in_where3 : Test(1) {
    
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

sub subquery_in_from : Test(1) {
    
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
