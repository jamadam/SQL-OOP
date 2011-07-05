package SQL::OOP::Base;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(Class::Data::Inheritable);
use 5.005;
    
    ### ---
    ### default quote character
    ### ---
    __PACKAGE__->mk_classdata(quote_char => q("));
    
    ### ---
    ### escape_code_ref for col names
    ### ---
    __PACKAGE__->mk_classdata(escape_code_ref => sub {
        my ($str, $quote_char) = @_;
        $str =~ s{$quote_char}{$quote_char$quote_char}g;
        return $str;
    });
    
    ### ---
    ### Constractor
    ### ---
    sub new {
        
        my ($class, $str, $bind_ref) = @_;
        if (ref $str && (ref($str) eq 'CODE')) {
            $str = $str->();
        }
        if (blessed($str) && $str->isa(__PACKAGE__)) {
            return $str;
        } elsif ($str) {
            if ($bind_ref && ! ref $bind_ref) {
                die '$bind_ref must be an Array ref';
            }
            return bless {
                str     => $str,
                gen     => undef,
                bind    => ($bind_ref || [])
            }, $class;
        }
        return;
    }
    
    ### ---
    ### Get SQL snippet
    ### ---
    sub to_string {
        
        my ($self, $prefix) = @_;
        if (! defined $self->{gen}) {
            $self->generate;
        }
        if ($self->{gen} && $prefix) {
            return $prefix. ' '. $self->{gen};
        } else {
            return $self->{gen};
        }
    }
    
    ### ---
    ### Get SQL snippet with values embeded [EXPERIMENTAL]
    ### ---
    sub to_string_embeded {
        
        my ($self, $quote_with) = @_;
        $quote_with ||= q{'};
        my $format = $self->to_string;
        $format =~ s{\?}{%s}g;
        return
        sprintf($format, map {$self->quote($_, $quote_with)} @{[$self->bind]});
    }
    
    ### ---
    ### Get binded values in array
    ### ---
    sub bind {
        
        my ($self) = @_;
        return @{$self->{bind} || []} if (wantarray);
        return scalar @{$self->{bind} || []};
    }
    
    ### ---
    ### initialize generated SQL
    ### ---
    sub _init_gen {
        
        my ($self) = @_;
        $self->{gen} = undef;
    }

    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my ($self) = @_;
        $self->{gen} = $self->{str} || '';
        return $self;
    }
    
    ### ---
    ### quote
    ### ---
    sub quote {
        
        my ($class, $val, $with) = @_;
        if (! $with) {
            if (blessed($class)) {
                $class = blessed($class);
            }
            $with = $class->quote_char;
        }
        $val = $class->escape_code_ref->($val, $with);
        return $with. $val. $with;
    }

### ---
### Array of SQL snippets
### ---
package SQL::OOP::Array;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP::Base);
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        my $self = bless {
            sepa    => ' ',
            gen     => undef,
            array   => undef,
        }, $class;
        
        return $self->append(@array);
    }
    
    ### ---
    ### Set separator for join array
    ### ---
    sub set_sepa {
        
        my ($self, $sepa) = @_;
        $self->{sepa} = $sepa;
        return $self;
    }
    
    ### ---
    ### Append snippet
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        foreach my $elem (@array) {
            if ($elem) {
                push(@{$self->{array}}, SQL::OOP::Base->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        my @array = map {
            if ($_->to_string && (scalar @{$self->{array}}) >= 2) {
                $self->fix_element_in_list_context($_);
            } else {
                $_->to_string;
            }
        } @{$self->{array}};
        $self->{gen} = join($self->{sepa}, grep {$_} @array);
        
        return $self;
    }
    
    ### ---
    ### fix generated string in list context
    ### ---
    sub fix_element_in_list_context {
        
        my ($self, $obj) = @_;
        if ($obj->isa(__PACKAGE__)) {
            return '('. $obj->to_string. ')';
        }
        return $obj->to_string;
    }
    
    ### ---
    ### Get binded values in array
    ### ---
    sub bind {
        
        my $self = shift;
        my @out = map {
            my @a;
            if ($_) {
                @a = $_->bind;
            }
            @a;
        } @{$self->{array}};
        return @out if (wantarray);
        return scalar @out;
    }

### ---
### Class for Identifier such as table, field schema
### ---
package SQL::OOP::ID::Parts;
use strict;
use warnings;
use base qw(SQL::OOP::Base);
    
    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        $self->SUPER::generate(@_);
        $self->{gen} = $self->quote($self->{gen});
    }

### ---
### Class for dot-chained Identifier ex) "public"."table"."colmun1"
### ---
package SQL::OOP::ID;
use strict;
use warnings;
use base qw(SQL::OOP::Array);
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        return $class->SUPER::new(@array)->set_sepa('.');
    }
    
    ### ---
    ### Append ID
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        for my $elem (@array) {
            if ($elem) {
                push(@{$self->{array}}, SQL::OOP::ID::Parts->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### "field AS foo" syntax
    ### ---
    sub as {
        
        my ($self, $as) = (@_);
        $self->{as} = $as;
        return $self;
    }
    
    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my $self = shift;
        my @array = map {$_->to_string} @{$self->{array}};
        $self->{gen} = join($self->{sepa}, grep {$_} @array);

        if ($self->{as}) {
            $self->{gen} .= ' AS '. $self->quote($self->{as});
        }
        
        return $self;
    }

### ---
### Class for array of identifier ex) "tbl1"."col1", "tbl1"."col2"...
### ---
package SQL::OOP::IDArray;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP::Array);
    
    ### ---
    ### constractor
    ### ---
    sub new {
        
        my ($class, @array) = @_;
        my $self = $class->SUPER::new(@array)->set_sepa(', ');
    }
    
    ### ---
    ### Append ID
    ### ---
    sub append {
        
        my ($self, @array) = @_;
        $self->_init_gen;
        if (ref $array[0] && ref $array[0] eq 'ARRAY') {
            @array = @{$array[0]};
        }
        foreach my $elem (@array) {
            if (blessed($elem) && $elem->isa('SQL::OOP::Base')) {
                push(@{$self->{array}}, $elem);
            } elsif ($elem) {
                push(@{$self->{array}}, SQL::OOP::ID->new($elem));
            }
        }
        return $self;
    }
    
    ### ---
    ### parenthisize sub query 
    ### ---
    sub fix_element_in_list_context {
        
        my ($self, $obj) = @_;
        if ($obj->isa('SQL::OOP::Command')) {
            return '('. $obj->to_string. ')';
        }
        return $obj->to_string;
    }

1;
__END__

=head1 NAME

SQL::OOP::Base - SQL Generator base class

=head1 SYNOPSIS
    
    my $sql = SQL::OOP::Base->new;
    
    ### Returns SQL::Abstract style values that can be thrown at DBI methods.
    my $sql  = $select->to_string;
    my @bind = $select->bind;
    
    ### field
    my $field_obj = SQL::OOP::ID->new(@path_to_field); # e.g. "tbl"."col"
    
    ### from
    my $from_obj = SQL::OOP::ID->new(@path_to_table); # e.g. "schema"."tbl"

=head1 DESCRIPTION

This module provides you an object oriented interface to generate SQL
statements. This doesn't require any complex syntaxed hash structure. All you
have to do is to call well-readable OOP methods.

SQL::OOP distibution includes some modules. This is the base class of them.
    
    SQL::OOP::Base [abstract]
        SQL::OOP::Array [abstract]
            SQL::OOP::ID
                SQL::OOP::IDArray
            SQL::OOP::Order
            SQL::OOP::Dataset
            SQL::OOP::Command [abstract]
                SQL::OOP::Select
                SQL::OOP::Insert
                SQL::OOP::Update
                SQL::OOP::Delete
            SQL::OOP::Order
    SQL::OOP::Where [factory]

Any instace returned by each class are capable of to_string() and bind(). These
methods returns similar values as SQL::Abstract. 

=head1 SQL::OOP::Base CLASS

This class represents SQLs or SQL snippets.

=head2 SQL::OOP::Base->new($str, $array_ref)
    
Constractor. It takes String and array ref.

    my $sql = SQL::OOP::Base->new('a = ? and b = ?', [10,20]);

=head2 SQL::OOP::Base->quote_char($quote_char)

=head2 SQL::OOP::Base->escape_code_ref($code_ref)

=head2 $instance->to_string()

This method returns the SQL string.

    $sql->to_string # 'a = ? and b = ?'

=head2 $instance->to_string_embeded() [EXPERIMENTAL]

This method returns the SQL string with binded values enbeded. This method aimed
at use of debugging.

    $sql->to_string_embeded # a = 'value' and b = 'value'

=head2 $instance->bind()

This method returns binded values in array.

    $sql->bind      # [10,20]

=head2 $instance->generate()

=head2 SQL::OOP::Base->quote()

=head1 SQL::OOP::Array CLASS

This is an abstract class that extends SQL::OOP::Base

=head2 $instance->append(@elements)

This method appends elements to the instance and returns $self;

=head1 SQL::OOP::ID CLASS

This class represents IDs such as table names, field names.

=head2 SQL::OOP::ID->new(@ids)

=head2 $instance->as($str)

Here is some examples.
    
    my $id_obj = SQL::OOP::ID->new('public', 'tbl1'); 
    $id_obj->to_string; # "public"."tbl1"
    
    $id_obj->as('TMP');
    $id_obj->to_string; # "public"."tbl1" AS TMP

=head1 SQL::OOP::IDArray CLASS

This class represents ID arrays such as field lists in SELECT or table lists
in FROM clause.

=head2 SQL::OOP::IDArray->new(@ids)

    my $id_list = SQL::OOP::IDArray->new('tbl1', 'tbl2', 'tbl3');
    
    $id_list->to_string; # "tbl1", "tbl2", "tbl3"    

=head2 SQL::OOP::IDArray->new(@id_objects)

Here is some examples.
    
    my $id_obj1 = SQL::OOP::ID->new('public', 'tbl1');
    my $id_obj2 = SQL::OOP::ID->new('public', 'tbl2');
    my $id_obj3 = SQL::OOP::ID->new('public', 'tbl3');
    
    my $id_list = SQL::OOP::IDArray->new($id_obj1, $id_obj2, $id_obj3);
    
    $id_list->to_string; # "public"."tbl1", "public"."tbl2", "public"."tbl3"

=head1 SEE ALSO

L<SQL::OOP::Order>
L<SQL::OOP::Dataset>
L<SQL::OOP::Command>
L<SQL::OOP::Select>
L<SQL::OOP::Insert>
L<SQL::OOP::Update>
L<SQL::OOP::Delete>
L<SQL::OOP::Where>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
