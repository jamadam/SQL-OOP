use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;

my $sql = SQL::OOP->new;

{
    my $a = $sql->base("a");
    is($a->to_string, 'a');
    is($a->to_string, 'a');
}

{
    my $a = $sql->array("a")->set_sepa(',');
    is($a->to_string, 'a');
    is($a->to_string, 'a');
}

{
    my $a = $sql->array($sql->base('a'), $sql->base('b'))->set_sepa(', ');
    is($a->to_string, 'a, b');
    is($a->to_string, 'a, b');
}

{
    
    my $select = $sql->select(
        fields => 'a',
        from   => 'b',
    );
    my $a = $sql->array($select)->set_sepa(', ');
    is($a->to_string, 'SELECT a FROM b');
    is($a->to_string, 'SELECT a FROM b');
}

{
    my $select = $sql->select(
        fields => 'a',
        from   => $sql->base('b'),
    );
    my $a = $sql->array($select)->set_sepa(', ');
    is($a->to_string, 'SELECT a FROM b');
    is($a->to_string, 'SELECT a FROM b');
}

{
    my $select = $sql->select(
        fields => 'a',
        from   => $sql->array('b')->set_sepa(''),
    );
    is($select->to_string, 'SELECT a FROM b');
    is($select->to_string, 'SELECT a FROM b');
}

{
    my $select = $sql->select(
        fields => 'a',
        from   => 'b',
    );
    my $select2 = $sql->select(
        fields    => 'a',
        from    => $select,
    );
    is($select2->to_string, 'SELECT a FROM (SELECT a FROM b)');
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
