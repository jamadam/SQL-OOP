package SQL_OOP_UpdateTest;
use strict;
use warnings;
use lib qw(t/lib);
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Update;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub set_clause_separately : Test(1) {
    
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

sub where : Test(3) {
    
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

sub values_by_array : Test(4) {
    
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

sub value_order_specific : Test(3) {
    
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

sub update_value_is_a_array : Test(3) {
    
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

sub conprehensive : Test(8) {
    
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
