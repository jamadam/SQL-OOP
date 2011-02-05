package Temp;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib', 'libext';
use SQL::OOP;
use SQL::OOP::Join;
use SQL::OOP::Where;
use SQL::OOP::Select;

__PACKAGE__->runtests;


sub function_in_field : Test(1) {
    
    my $select = SQL::OOP::Select->new;
    $select->set(
        $select->ARG_FIELDS => 'max(a) AS b',
        $select->ARG_FROM   => 'tbl',
    );
	is($select->to_string, 'SELECT max(a) AS b FROM tbl');
}

sub compress_sql {
    
    my $sql = shift;
    $sql =~ s/[\s\r\n]+/ /gs;
    $sql =~ s/[\s\r\n]+$//gs;
    $sql =~ s/\(\s/\(/gs;
    $sql =~ s/\s\)/\)/gs;
    return $sql;
}