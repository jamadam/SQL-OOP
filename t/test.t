package SQL_OOP_CpmprehensiveTest;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::IDArray;
use SQL::OOP::Select;
use SQL::OOP::Dataset;

    __PACKAGE__->runtests;
    
    sub select_basic : Test {
        
        my ($fields, $where, $limit) = @_;
        
        my $a = SQL::OOP::Dataset->new(a => '1', b => undef);
        warn $a->to_string_for_insert;
        warn scalar $a->bind;
    }
