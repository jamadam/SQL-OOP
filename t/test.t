package SQL_OOP_Sql;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Array;
use SQL::OOP::Insert;
use SQL::OOP::Where;
    
    __PACKAGE__->runtests;
    
    sub set_quote_deep : Test(1) {
        my $elem = SQL::OOP::ID->new('a');
        my $array = SQL::OOP::Array->new($elem, $elem);
        $array->quote_char(q{`});
        is $array->to_string, q{(`a`) (`a`)};
    }
    
    sub compress_sql {
        
        my $sql = shift;
        $sql =~ s/[\s\r\n]+/ /gs;
        $sql =~ s/[\s\r\n]+$//gs;
        $sql =~ s/\(\s/\(/gs;
        $sql =~ s/\s\)/\)/gs;
        return $sql;
    }