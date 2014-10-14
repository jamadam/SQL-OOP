use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;

my $sql = SQL::OOP->new;

{
    my $in = $sql->where->not_in('col', [1, 2, 3]);
    is($in->to_string, q{"col" NOT IN (?, ?, ?)});
    my @bind = $in->bind;
    is(scalar @bind, 3);
    is(shift @bind, '1');
    is(shift @bind, '2');
    is(shift @bind, '3');

    my $sub = SQL::OOP::Select->new;
    $sub->set(
        fields => '*',
        from => 'tbl',
    );
    $in = $sql->where->not_in('col', $sub);
    is($in->to_string, q{"col" NOT IN (SELECT * FROM tbl)});
}

{
    my $in = $sql->where->in('col', 'hoge');
    is($in->to_string, q{"col" IN (?)});
    my @bind = $in->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'hoge');
    
    $in = $sql->where->in('col', undef);
    is($in, undef);
    
    $in = $sql->where->in('col', 0);
    is($in->to_string, q{"col" IN (?)});
    @bind = $in->bind;
    is(scalar @bind, 1);
    is(shift @bind, 0);
    
    $in = $sql->where->in('col', [1, 2, 3]);
    is($in->to_string, q{"col" IN (?, ?, ?)});
    @bind = $in->bind;
    is(scalar @bind, 3);
    is(shift @bind, '1');
    is(shift @bind, '2');
    is(shift @bind, '3');
    
    $in = $sql->where->in('col', 1, 2, 3);
    is($in->to_string, q{"col" IN (?, ?, ?)});
    @bind = $in->bind;
    is(scalar @bind, 3);
    is(shift @bind, '1');
    is(shift @bind, '2');
    is(shift @bind, '3');
    
    my $sub = $sql->select;
    $sub->set(
        fields => '*',
        from => 'tbl',
        where  => $sql->where->cmp('=', 'a', 'b'),
    );
    $in = $sql->where->in('col', $sub);
    is($in->to_string, q{"col" IN (SELECT * FROM tbl WHERE "a" = ?)});
    @bind = $in->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'b');
    
    $sub = $sql->select;
    $sub->set(
        fields => '*',
        from => 'tbl',
        where  => $sql->where->cmp('=', 'a', 'b'),
    );
    $in = $sql->where->in('col', $sub, $sub);
    is($in->to_string, q{"col" IN (SELECT * FROM tbl WHERE "a" = ?, SELECT * FROM tbl WHERE "a" = ?)});
    @bind = $in->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, 'b');
}

{
    my $a = $sql->where->cmp('=', 'a', undef);
    is($a, undef);
}

{
    my $base = SQL::OOP::Base->new('test');
    {
        my $a = $sql->where->cmp('=', 'col1', $base);
        is($a->to_string, '"col1" = test');
    }
    {
        my $a = $sql->where->cmp('=', SQL::OOP::ID->new('col1'), $base);
        is($a->to_string, '"col1" = test');
    }
}

{
    my $a = $sql->where->cmp('=', SQL::OOP::Base->new('func(col1)'),
                                    SQL::OOP::Base->new('func(col2)'));
    is($a->to_string, q{func(col1) = func(col2)});
}

{
    my $obj = $sql->where->cmp('=', 'key1', 'val1');
    is($obj->to_string, q{"key1" = ?});
    my $obj2 = $sql->where->or();
    $obj2->append($sql->where->cmp('=', 'key2', 'val2'));
    is($obj2->to_string, q{"key2" = ?});
    $obj2->append($sql->where->or(
        $sql->where->cmp('=', 'key3', 'val3'),
        $sql->where->cmp('=', 'key4', 'val4')
    ));
    is($obj2->to_string, q{"key2" = ? OR ("key3" = ? OR "key4" = ?)});
}

{
    my $and = $sql->where->and('a','b');
    is($and->to_string, q{a AND b});
}

{
    my $and = $sql->where->and(sub{'a'},sub{'b'}->());
    is($and->to_string, q{a AND b});
}

{
    my $seed = [
        a => 'b',
        c => 'd',
    ];
    my $where = $sql->where->and_abstract($seed);
    is($where->to_string, q{"a" = ? AND "c" = ?});
}

{
    my $seed = [
        a => 'b',
        c => 'd',
    ];
    my $where = $sql->where->and_abstract($seed, "LIKE");
    is($where->to_string, q{"a" LIKE ? AND "c" LIKE ?});
}

{
    my $seed = [
        a => 'b',
        c => 'd',
    ];
    my $where = $sql->where->or_abstract($seed);
    is($where->to_string, q{"a" = ? OR "c" = ?});
}

{
    my $id = $sql->id('public','table','c1');
    is($id->to_string, q{"public"."table"."c1"});
    my $where = $sql->where->cmp('=', $id, 'val');
    is($where->to_string, q{"public"."table"."c1" = ?});
}

{
    my $where = $sql->where->cmp('=', ['public','table','c1'], 'val');
    is($where->to_string, q{"public"."table"."c1" = ?});
}

{
    my $where = $sql->where->is_null('col1');
    is($where->to_string, q{"col1" IS NULL});
    my $where2 = $sql->where->is_null($sql->id('col1'));
    is($where2->to_string, q{"col1" IS NULL});
}

{
    my $where = $sql->where->between('col1', 1, 2);
    is($where->to_string, q{"col1" BETWEEN ? AND ?});
    my $where2 = $sql->where->between($sql->id('col1'), 1, 2);
    is($where2->to_string, q{"col1" BETWEEN ? AND ?});
}

{
    my $where = $sql->where->between('col1', 1, undef);
    is($where->to_string, q{"col1" >= ?});
    my $where2 = $sql->where->between($sql->id('col1'), 1, undef);
    is($where2->to_string, q{"col1" >= ?});
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
