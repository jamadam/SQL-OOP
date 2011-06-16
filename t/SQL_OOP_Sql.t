package SQL_OOP_Sql;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use SQL::OOP;
use SQL::OOP::Insert;
use SQL::OOP::Where;
    
    __PACKAGE__->runtests;
    
    sub bind_include_undef : Test(5) {
        
        my $sql = SQL::OOP->new('a', ['a', undef, 'c']);
        is($sql->to_string, 'a');
        my @bind = $sql->bind;
        is(scalar @bind, 3);
        is(shift @bind, 'a');
        is(shift @bind, undef);
        is(shift @bind, 'c');
    }
    
    sub array : Test {
        
        my $sql = SQL::OOP::Array->new('a', 'b', 'c')->set_sepa(',');
        is($sql->to_string, q{a,b,c});
    }
    
    sub array_include_undef : Test {
        
        my $sql = SQL::OOP::Array->new('a', undef, 'c')->set_sepa(',');
        is($sql->to_string, q{a,c});
    }
    
    sub array_basic : Test(5) {
        
        my $sql1 = SQL::OOP->new('a', ['a']);
        my $sql2 = SQL::OOP->new('b', ['b']);
        my $sql3 = SQL::OOP->new('c', ['c']);
        my $sql = SQL::OOP::Array->new($sql1, $sql2, $sql3)->set_sepa(',');
        is($sql->to_string, q{a,b,c});
        my @bind = $sql->bind;
        is(scalar @bind, 3);
        is(shift @bind, 'a');
        is(shift @bind, 'b');
        is(shift @bind, 'c');
    }
    
    sub array_basic_include_undef : Test(5) {
        
        my $sql1 = SQL::OOP->new('a', ['a']);
        my $sql2 = SQL::OOP->new('b', [undef]);
        my $sql3 = SQL::OOP->new('c', ['c']);
        my $sql = SQL::OOP::Array->new($sql1, $sql2, $sql3)->set_sepa(',');
        is($sql->to_string, q{a,b,c});
        my @bind = $sql->bind;
        is(scalar @bind, 3);
        is(shift @bind, 'a');
        is(shift @bind, undef);
        is(shift @bind, 'c');
    }
    
    sub array_basic_include_undef2 : Test(5) {
        
        my $sql1 = SQL::OOP->new('a', ['a']);
        my $sql2 = SQL::OOP->new('b', undef);
        my $sql3 = SQL::OOP->new('c', ['c']);
        my $sql = SQL::OOP::Array->new($sql1, $sql2, $sql3)->set_sepa(',');
        is($sql->to_string, q{a,b,c});
        my @bind = $sql->bind;
        is(scalar @bind, 2);
        is(shift @bind, 'a');
        is(shift @bind, 'c');
    }
    
    sub quote : Test {
        
        my $sql = SQL::OOP::ID->new('a');
        is($sql->to_string, q{"a"});
    }
    
    sub set_quote : Test {
        
        my $id = SQL::OOP::ID->new('a');
        my $backup = SQL::OOP->quote_char;
        SQL::OOP->quote_char(q(`));
        is($id->to_string, q{`a`});
        SQL::OOP->quote_char($backup);
    }
    
    sub arrayed_construction : Test(4) {
        
        my $expected = compress_sql(<<EOF);
SELECT
    *
FROM
    tbl1
WHERE
    "a" = ?
EOF
        
        ### case 1
        {
            my $sql = SQL::OOP::Array->new(
                'SELECT', '*', 'FROM', 'tbl1', 'WHERE', '"a" = ?');
            is($sql->to_string, $expected);
        }
        
        ### case 2
        {
            my $cond = SQL::OOP::Where->cmp('=', 'a', 'b');
            my $sql = SQL::OOP::Array->new(
                'SELECT', '*', 'FROM', 'tbl1', 'WHERE', $cond);
            my @bind = $sql->bind;
            is($sql->to_string, $expected);
            is(scalar @bind, 1);
            is(shift @bind, 'b');
        }
    }
    
    sub to_string_embeded : Test(2) {
        my $cond = SQL::OOP::Where->cmp('=', 'a', 'b');
        my $sql = SQL::OOP::Array->new(
            'SELECT', '*', 'FROM', 'tbl1', 'WHERE', $cond);
        my @bind = $sql->bind;
        is($sql->to_string_embeded, q{SELECT * FROM tbl1 WHERE "a" = 'b'});
        is($sql->to_string_embeded(q{`}), q{SELECT * FROM tbl1 WHERE "a" = `b`});
    }
    
    sub compress_sql {
        
        my $sql = shift;
        $sql =~ s/[\s\r\n]+/ /gs;
        $sql =~ s/[\s\r\n]+$//gs;
        $sql =~ s/\(\s/\(/gs;
        $sql =~ s/\s\)/\)/gs;
        return $sql;
    }