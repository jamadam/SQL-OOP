use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Join;
use SQL::OOP::Where;
use SQL::OOP::Insert;
use SQL::OOP::Dataset;

my $sql = SQL::OOP->new;

{
    
    my $users = _insert_user('jamadam', ['point' => '10']);
    is($users->to_string, q{INSERT INTO "user" ("point") VALUES (?)});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, 10);
}

{
    my $users = _insert_user('jamadam', ['point' => undef]);
    is($users->to_string, q{INSERT INTO "user" ("point") VALUES (?)});
    my @bind = $users->bind;
    is(scalar @bind, 1);
    is(shift @bind, undef);
}

sub _insert_user {
    
    my ($userid, $dataset_ref) = @_;
    my $insert = $sql->insert(
        table     => $sql->id('user'),
        dataset   => $sql->dataset($dataset_ref),
    );
    return $insert;
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
