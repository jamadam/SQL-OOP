use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Dataset;

my $sql = SQL::OOP->new;

{
    my $dataset = $sql->dataset;
    $dataset->append(a => 'b');
    $dataset->append(c => 'd');
    is($dataset->to_string_for_insert, q(("a", "c") VALUES (?, ?)));
    is($dataset->to_string_for_update, q("a" = ?, "c" = ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $dataset = $sql->dataset;
    $dataset->append(a => 'b');
    $dataset->append(c => 'd');
    is($dataset->to_string_for_insert, q(("a", "c") VALUES (?, ?)));
    is($dataset->to_string_for_update, q("a" = ?, "c" = ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $dataset = $sql->dataset([a => 'b', c => 'd']);
    is($dataset->to_string_for_insert, q(("a", "c") VALUES (?, ?)));
    is($dataset->to_string_for_update, q("a" = ?, "c" = ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, 'd');
}

{
    my $dataset = $sql->dataset;
    $dataset->append(a => 'b');
    $dataset->append(c => undef);
    is($dataset->to_string_for_insert, q(("a", "c") VALUES (?, ?)));
    is($dataset->to_string_for_update, q("a" = ?, "c" = ?));
    my @bind = $dataset->bind;
    is(scalar @bind, 2);
    is(shift @bind, 'b');
    is(shift @bind, undef);
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
