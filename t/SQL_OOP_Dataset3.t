package SQL_OOP_CpmprehensiveTest;
use strict;
use warnings;
use lib qw(lib);
use lib qw(t/lib);
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Dataset;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub retrieve : Test(2) {
    my $dataset = $sql->dataset;
    $dataset->append(a => 'b', c => 'd');
    is $dataset->retrieve('a'), 'b', 'right value';
    is $dataset->retrieve('c'), 'd', 'right value';
}
