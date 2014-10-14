package Temp;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Join;
use SQL::OOP::Where;
use SQL::OOP::Select;
use SQL::OOP::IDArray;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub default_cond_and_flex_cond : Test(4) {
    
    my $users = _active_users(['point' => '10']);
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ? AND ("point" = ?)});
    my @bind = $users->bind;
    is(scalar @bind, 2);
    is(shift @bind, 1);
    is(shift @bind, 10);
}

sub default_cond_and_flex_cond_undef : Test(3) {
    
    my $users = _active_users(['point' => undef]);
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ?});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, 1);
}

sub _active_users {
    
    my $where_abstract = shift;
    
    my $select = $sql->select;
    $select->set(
        fields => $sql->id_array('a','b'),
        from   => $sql->id_array('user'),
        where  => $sql->where->and(
            $sql->where->cmp('=', 'active', '1'),
            $sql->where->and_abstract($where_abstract),
        )
    );
    return $select;
}

sub default_cond_and_flex_cond2 : Test(4) {
    
    my $users = _active_users2($sql->where->cmp('>', 'point', '100'));
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ? AND "point" > ?});
    my @bind = $users->bind;
    is(scalar @bind, 2);
    is(shift @bind, 1);
    is(shift @bind, 100);
}

sub default_cond_and_flex_cond2_undef : Test(3) {
    
    my $users = _active_users2($sql->where->cmp('>', 'point', undef));
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ?});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, 1);
}

sub default_cond_and_flex_cond2_undef2 : Test(3) {
    
    my $users = _active_users2(undef);
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ?});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, 1);
}

sub _active_users2 {
    
    my $where_obj = shift;
    
    my $select = $sql->select;
    $select->set(
        fields => $sql->id_array('a','b'),
        from   => $sql->id_array('user'),
        where  => $sql->where->and(
            $sql->where->cmp('=', 'active', '1'),
            $where_obj,
        )
    );
    return $select;
}

sub compress_sql {
    
    my $sql = shift;
    $sql =~ s/[\s\r\n]+/ /gs;
    $sql =~ s/[\s\r\n]+$//gs;
    $sql =~ s/\(\s/\(/gs;
    $sql =~ s/\s\)/\)/gs;
    return $sql;
}