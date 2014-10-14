use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Dataset;

my $sql = SQL::OOP->new;

{
    my $dataset = $sql->dataset;
    $dataset->append(a => $sql->base(q{datetime('now', 'localtime')}));
    is($dataset->to_string_for_insert, q(("a") VALUES (datetime('now', 'localtime'))));
    my @bind = $dataset->bind;
    is(scalar @bind, 0);
}

{
    my $dataset = $sql->dataset;
    $dataset->append(a => $sql->base(q{datetime('now', 'localtime')}));
    is($dataset->to_string_for_update, q("a" = datetime('now', 'localtime')));
    my @bind = $dataset->bind;
    is(scalar @bind, 0);
}

{
    my $dataset = $sql->dataset;
    $dataset->append(a => $sql->base(q{"a" + 1}));
    is($dataset->to_string_for_update, q("a" = "a" + 1));
    my @bind = $dataset->bind;
    is(scalar @bind, 0);
}

{
    my $dataset = $sql->dataset;
    $dataset->append(a => $sql->base(q{"a" + ?}, [1]));
    is($dataset->to_string_for_update, q("a" = "a" + ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 1);
    is(shift @bind, '1');
}

{
    my $dataset = $sql->dataset;
    $dataset->append(
        a => $sql->base(q{"a" + ?}, [1])
    );
    is($dataset->to_string_for_update, q("a" = "a" + ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 1);
    is(shift @bind, '1');
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
