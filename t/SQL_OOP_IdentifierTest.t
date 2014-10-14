use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::IDArray;
use SQL::OOP::Select;

my $sql = SQL::OOP->new;

{
    my $table = $sql->id('tbl1')->as('T1');
    is($table->to_string, q{"tbl1" AS "T1"});
}

{
    my $fields = $sql->id('public', 'tbl1');
    my $sql = $fields->to_string;
    is($sql, q{"public"."tbl1"});
}

{
    my $fields = $sql->id('public', 'tbl1')->as('T1');
    my $sql = $fields->to_string;
    is($sql, q{"public"."tbl1" AS "T1"});
}

{
    my $fields = $sql->id_array(qw(a b c));
    my $sql = $fields->to_string;
    is($sql, qq{"a", "b", "c"});
}

{
    my $fields = $sql->id_array(qw(a));
    is($fields->to_string, qq{"a"});
}

{
    my $fields = $sql->id_array(qw(a));
    $fields->append('b');
    is($fields->to_string, qq{"a", "b"});
}

{
    my $fields = $sql->id_array(qw(a b c));
    $fields->append($sql->base('*'));
    is($fields->to_string, qq{"a", "b", "c", *});
}

{
    my $fields = $sql->id_array(qw(a b c));
    my $sub_query = $sql->select;
    $sub_query->set(
        fields  => 'hoge',
        where   => 'a = b',
    );
    $fields->append($sub_query);
    is($fields->to_string, qq{"a", "b", "c", (SELECT hoge WHERE a = b)});
}

{
    my $select = $sql->select;
    $select->set(
        fields => $sql->id_array(
            $sql->id('column1'),
            $sql->base('count(*) AS "B"'),
        ),
    );
    is($select->to_string, q{SELECT "column1", count(*) AS "B"});
}

{
    my $sql = $sql->array('a', 'b', $sql->id('c'))->set_sepa(',');
    is($sql->to_string, q{a,b,("c")});
}

{
    my $sql = $sql->id('a', 'b', $sql->base('c'));
    is($sql->to_string, q{"a"."b".c});
}

{
    my $id = $sql->id('public','table','c1');
    is($id->to_string, q{"public"."table"."c1"});
}

{
    my $id_part = SQL::OOP::ID::Parts->new('test"test');
    is($id_part->to_string, q{"test""test"});
    my $id = $sql->id('table"1', 'column"1');
    is($id->to_string, q{"table""1"."column""1"});
}

{
    my $id = $sql->id(['schema', 'table', 'col']);
    is($id->to_string, q{"schema"."table"."col"});
}

{
    my $id = $sql->id_array([['schema', 'table', 'col1'], ['schema', 'table', 'col2']]);
    is($id->to_string, q{"schema"."table"."col1", "schema"."table"."col2"});
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
