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
        dataset => sub {
            my $ds = $sql->dataset;
            $ds->append('a' => $sql->base(q{"a" + ?}, [1]))
        },
        where => $sql->where->cmp('=', 'a', 'b'),
    );
    
    is($update->to_string, q(UPDATE tbl1 SET "a" = "a" + ? WHERE "a" = ?));
    my @bind = $update->bind;
    is(scalar @bind, 2);
    is(shift @bind, 1);
    is(shift @bind, 'b');
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
