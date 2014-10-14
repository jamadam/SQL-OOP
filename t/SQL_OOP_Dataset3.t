use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Dataset;

my $sql = SQL::OOP->new;

{
    my $dataset = $sql->dataset;
    $dataset->append(a => 'b', c => 'd');
    is $dataset->retrieve('a'), 'b', 'right value';
    is $dataset->retrieve('c'), 'd', 'right value';
}

done_testing();
