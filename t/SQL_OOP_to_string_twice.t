package SQL_OOP_CpmprehensiveTest;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Select;

__PACKAGE__->runtests;

my $sql;

sub setup : Test(setup) {
    $sql = SQL::OOP->new;
};

sub to_string_twice : Test(2) {
    
    my $a = $sql->base("a");
    is($a->to_string, 'a');
    is($a->to_string, 'a');
}

sub array_to_string_twice : Test(2) {
    
    my $a = $sql->array("a")->set_sepa(',');
    is($a->to_string, 'a');
    is($a->to_string, 'a');
}

sub array_to_string_twice2 : Test(2) {
    
    my $a = $sql->array($sql->base('a'), $sql->base('b'))->set_sepa(', ');
    is($a->to_string, 'a, b');
    is($a->to_string, 'a, b');
}

sub select_to_string_twice1 : Test(2) {
    
    my $select = $sql->select(
        fields => 'a',
        from   => 'b',
    );
    my $a = $sql->array($select)->set_sepa(', ');
    is($a->to_string, 'SELECT a FROM b');
    is($a->to_string, 'SELECT a FROM b');
}

sub select_to_string_twice2 : Test(2) {
    
    my $select = $sql->select(
        fields => 'a',
        from   => $sql->base('b'),
    );
    my $a = $sql->array($select)->set_sepa(', ');
    is($a->to_string, 'SELECT a FROM b');
    is($a->to_string, 'SELECT a FROM b');
}

sub select_to_string_twice3 : Test(2) {
    
    my $select = $sql->select(
        fields => 'a',
        from   => $sql->array('b')->set_sepa(''),
    );
    is($select->to_string, 'SELECT a FROM b');
    is($select->to_string, 'SELECT a FROM b');
}

sub select_to_string_twice4 : Test(1) {
    
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
