use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Join;
use SQL::OOP::Where;
use SQL::OOP::Select;
use SQL::OOP::IDArray;

my $sql = SQL::OOP->new;

{
    my $users = _active_users(['point' => '10']);
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ? AND ("point" = ?)});
    my @bind = $users->bind;
    is(scalar @bind, 2);
    is(shift @bind, 1);
    is(shift @bind, 10);
}

{
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

{
    my $users = _active_users2($sql->where->cmp('>', 'point', '100'));
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ? AND "point" > ?});
    my @bind = $users->bind;
    is(scalar @bind, 2);
    is(shift @bind, 1);
    is(shift @bind, 100);
}

{
    my $users = _active_users2($sql->where->cmp('>', 'point', undef));
    is($users->to_string, q{SELECT "a", "b" FROM "user" WHERE "active" = ?});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, 1);
}

{
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

done_testing();
