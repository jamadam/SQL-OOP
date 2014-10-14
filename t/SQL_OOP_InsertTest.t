use strict;
use warnings;
use Test::More;
use SQL::OOP;
use SQL::OOP::Insert;

my $sql = SQL::OOP->new;

{
    my $insert = $sql->insert;
    $insert->set(
        table => 'key1',
    );
    $insert->set(
        dataset => '(a) VALUES (b)',
    );
    
    is($insert->to_string, q(INSERT INTO key1 (a) VALUES (b)));
}

{
    my $expected1 = compress_sql(<<EOF);
INSERT INTO "tbl1" ("col1", "col2") VALUES (?, ?)
EOF
    
    {
        my $insert = $sql->insert;
        $insert->set(
            table => '"tbl1"',
            dataset => $sql->dataset(col1 => 'a', col2 => 'b')
        );
        
        my @bind = $insert->bind;
        is($insert->to_string, $expected1);
        is(scalar @bind, 2);
        is(shift @bind, 'a');
        is(shift @bind, 'b');
    }
    {
        my @vals = (
            ['col1', 'val1'],
            ['col2', 'val2'],
        );
        
        my $dataset = $sql->dataset;
        foreach my $rec (@vals) {
            $dataset->append($rec->[0] => $rec->[1]);
        }
        my $insert = $sql->insert;
        $insert->set(
            table => '"tbl1"',
            dataset => $dataset,
        );
        
        my @bind = $insert->bind;
        is($insert->to_string, $expected1);
        is(scalar @bind, 2);
        is(shift @bind, 'val1');
        is(shift @bind, 'val2');
    }
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
