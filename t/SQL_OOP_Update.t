use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Update;

my $sql = SQL::OOP->new;

{
    my $update = $sql->update;
    $update->set(
        table => 'tbl1',
        dataset => 'a = b, c = d',
    );
    $update->set(
        where => 'some cond',
    );
    
    is($update->to_string, q(UPDATE tbl1 SET a = b, c = d WHERE some cond));
}

{
    my $update = $sql->update;
    $update->set(
        table => 'tbl1',
        dataset => 'a = ?, b = ?',
    );
    $update->set(
        where => $sql->where->cmp('=', 'a', 'b'),
    );
    
    is($update->to_string, q(UPDATE tbl1 SET a = ?, b = ? WHERE "a" = ?));
    my @bind = $update->bind;
    is(scalar @bind, 1);
    is(shift @bind, 'b');
}

{
    my $update = $sql->update;
    $update->set(
        dataset => $sql->dataset(a => 'b',c => 'd'),
    );
    is($update->to_string, 'SET "a" = ?, "c" = ?');
    my @bind = $update->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $update = $sql->update;
    $update->set(
        dataset =>
            $sql->dataset->append(a => 'b')->append(c => 'd'),
    );
    is($update->to_string, 'SET "a" = ?, "c" = ?');
    my @bind = $update->bind;
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $array = $sql->array->set_sepa(', ');
    $array->append($sql->base('a = ?', ['b']));
    $array->append($sql->base('c = ?', ['d']));
    my $sql = $sql->update;
    $sql->set(
        dataset => $array,
    );
    is($sql->to_string, 'SET a = ?, c = ?');
    my @bind = $sql->bind;
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $expected = compress_sql(<<EOF);
UPDATE tbl1 SET "a" = ? WHERE "c" = ?
EOF
    
    {
        my $update = $sql->update;
        $update->set(
            table => 'tbl1',
            dataset => $sql->dataset(a => 'b'),
            where => $sql->where->cmp('=', 'c', 'd'),
        );
        is($update->to_string, $expected);
        my @bind = $update->bind;
        is(scalar @bind, 2);
        is(shift @bind, 'b');
        is(shift @bind, 'd');
    }
    
    {
        my $update = $sql->update;
        $update->set(
            table => 'tbl1',
            dataset => $sql->dataset(a => 'b'),
            where => $sql->where->cmp('=', 'c', 'd'),
        );
        is($update->to_string, $expected);
        my @bind = $update->bind;
        is(scalar @bind, 2);
        is(shift @bind, 'b');
        is(shift @bind, 'd');
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
