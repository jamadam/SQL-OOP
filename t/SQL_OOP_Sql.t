use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Array;
use SQL::OOP::Insert;
use SQL::OOP::Where;

my $sql = SQL::OOP->new;

{
    my $base = $sql->base('a', ['a', undef, 'c']);
    is($base->to_string, 'a');
    my @bind = $base->bind;
    is(scalar @bind, 3);
    is(shift @bind, 'a');
    is(shift @bind, undef);
    is(shift @bind, 'c');
}

{
    my $array = $sql->array('a', 'b', 'c')->set_sepa(',');
    is($array->to_string, q{a,b,c});
}

{
    my $array = $sql->array('a', undef, 'c')->set_sepa(',');
    is($array->to_string, q{a,c});
}

{
    my $sql1 = $sql->base('a', ['a']);
    my $sql2 = $sql->base('b', ['b']);
    my $sql3 = $sql->base('c', ['c']);
    my $array = $sql->array($sql1, $sql2, $sql3)->set_sepa(',');
    is($array->to_string, q{a,b,c});
    my @bind = $array->bind;
    is(scalar @bind, 3);
    is(shift @bind, 'a');
    is(shift @bind, 'b');
    is(shift @bind, 'c');
}

{
    my $sql1 = $sql->base('a', ['a']);
    my $sql2 = $sql->base('b', [undef]);
    my $sql3 = $sql->base('c', ['c']);
    my $array = $sql->array($sql1, $sql2, $sql3)->set_sepa(',');
    is($array->to_string, q{a,b,c});
    my @bind = $array->bind;
    is(scalar @bind, 3);
    is(shift @bind, 'a');
    is(shift @bind, undef);
    is(shift @bind, 'c');
}

{
    my $sql1 = $sql->base('a', ['a']);
    my $sql2 = $sql->base('b', undef);
    my $sql3 = $sql->base('c', ['c']);
    my $array = $sql->array($sql1, $sql2, $sql3)->set_sepa(',');
    is($array->to_string, q{a,b,c});
    my @bind = $array->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'a');
    is(shift @bind, 'c');
}

{
    my $id = $sql->id('a');
    is($id->to_string, q{"a"});
}

{
    
    my $id = $sql->id('a');
    $id->quote_char(q(`));
    is($id->to_string, q{`a`});
}

{
    my $elem = $sql->id('a');
    my $array = $sql->array($elem, $elem);
    $array->quote_char(q{`});
    is $array->to_string, q{(`a`) (`a`)};
}

{
    my $expected = compress_sql(<<EOF);
SELECT
    *
FROM
    tbl1
WHERE
    "a" = ?
EOF
    
    ### case 1
    {
        my $array = $sql->array(
            'SELECT', '*', 'FROM', 'tbl1', 'WHERE', '"a" = ?');
        is($array->to_string, $expected);
    }
    
    ### case 2
    {
        my $cond = $sql->where->cmp('=', 'a', 'b');
        my $array = $sql->array(
            'SELECT', '*', 'FROM', 'tbl1', 'WHERE', $cond);
        my @bind = $array->bind;
        is($array->to_string, $expected);
        is(scalar @bind, 1);
        is(shift @bind, 'b');
    }
}

{
    my $cond = $sql->where->cmp('=', 'a', 'b');
    my $array = $sql->array(
        'SELECT', '*', 'FROM', 'tbl1', 'WHERE', $cond);
    my @bind = $array->bind;
    is($array->to_string_embedded, q{SELECT * FROM tbl1 WHERE "a" = 'b'});
    is($array->to_string_embedded(q{`}), q{SELECT * FROM tbl1 WHERE "a" = `b`});
}

{
    my $array = $sql->array('a', 'b', 'c');
    my @a = $array->values;
    is scalar @a, 3;
    is $a[0]->to_string, 'a';
    is $a[1]->to_string, 'b';
    is $a[2]->to_string, 'c';

    my $idarray = $sql->id_array([['A','B'],['C','D']]);
    @a = $idarray->values;
    is scalar @a, 2;
    is $a[0]->to_string, '"A"."B"';
    is $a[1]->to_string, '"C"."D"';
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
