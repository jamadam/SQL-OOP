package SQL::OOP;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(Class::Data::Inheritable);
use 5.005;
our $VERSION = '0.06';
	
	### ---
	### default quote character
	### ---
	__PACKAGE__->mk_classdata(quote_char => q("));
	
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
			return bless {
				str 	=> $str,
				gen 	=> undef,
				bind 	=> ($bind_ref || [])
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
		if (blessed($class)) {
			$class = blessed($class);
		}
		$with ||= $class->quote_char;
		return $with. $val. $with;
	}

### ---
### Array of SQL snippets
### ---
package SQL::OOP::Array;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP);
	
	### ---
	### constractor
	### ---
	sub new {
		
		my ($class, @array) = @_;
		my $self = bless {
			sepa	=> ' ',
			gen 	=> undef,
			array 	=> undef,
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
		foreach my $elem (@array) {
			if ($elem) {
				push(@{$self->{array}}, SQL::OOP->new($elem));
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
				$_->to_string
			}
		} @{$self->{array}};
		#$self->{gen} = smart_join($self->{sepa}, @array);
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
use base qw(SQL::OOP);
	
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
#use SQL::OOP::Util qw(smart_join);
	
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
		#$self->{gen} = smart_join($self->{sepa}, @array);
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
		foreach my $elem (@array) {
			if (blessed($elem) && $elem->isa('SQL::OOP')) {
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

SQL::OOP - SQL utilities

=head1 SYNOPSIS
	
	use SQL::OOP::Select;
	use SQL::OOP::Insert;
	use SQL::OOP::Update;
	use SQL::OOP::Delete;
	use SQL::OOP::Dataset;
	use SQL::OOP::Where;
	
	my $select = SQL::OOP::Select->new;
	my $insert = SQL::OOP::Insert->new;
	my $update = SQL::OOP::Update->new;
	my $delete = SQL::OOP::Delete->new;
	
	$select->set(%args);
	$insert->set(%args);
	$upadte->set(%args);
	$delete->set(%args);
	
	### Returns SQL::Abstract style values that can be thrown at DBI methods.
	my $sql  = $select->to_string;
	my @bind = $select->bind;

	### where factory for convinient
	my $where_fac = SQL::OOP::Where->new;
	
	### where elements
	my $where_obj1 = $where_fac->cmp('=', $col, $value);
	my $where_obj2 = $where_fac->is_null($col);
	my $where_obj3 = $where_fac->is_not_null($col);
	my $where_obj4 = $where_fac->between($col, $low, $high);
	
	### where element array
	my $where_and = $where_fac->and($sql_obj1, $sql_obj2, ...);
	my $where_or  = $where_fac->or($sql_obj1, $sql_obj2, ...);
	
	### array can be nested
	my $where_total = $where_fac->and($where_and, $where_or, ...);
	
	### field
	my $field_obj = SQL::OOP::ID->new(@path_to_field); # ex. "tbl"."col"
	
	### from
	my $from_obj = SQL::OOP::ID->new(@path_to_table); # ex. "schema"."tbl"
	
	### All argument names are provided by upper case methods
	$select->set(
		$select->FIELD => $field_obj,
		$select->FROM  => $from_obj,
		$select->WHERE => $where_total,
	);
	
	### Any SQL::OOP instance is capable of to_string()
	$sql = $where_obj1->to_string;
	$sql = $where_and->to_string;
	$sql = $where_total->to_string;
	$sql = $field_obj->to_string;
	
	### Any SQL::OOP instance can be part of others.
	my $select2 = SQL::OOP::Select->new;
	$select2->set(
		$select->FIELD => $field_obj,
		$select->FROM  => $select, ### sub query
	);
	
	### Argument can be set with annonymos subs
	$select->set($name => sub {return $sql_obj});

=head1 DESCRIPTION

This module provides you an object oriented interface to generate SQL statement.
This does not require any complex syntaxed hash structure. All you have to do is
to call well-readable methods.

This module includes some libs. SQL::OOP is the base class of them.

	SQL::OOP
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
		SQL::OOP::ID::Part [abstract]
		SQL::OOP::Order
	SQL::OOP::Where [factory]
	SQL::OOP::Util

SQL::OOP also has a factory class SQL::OOP::Where for core libruary. This
implements many constractors which returns a instance of SQL::OOP or its
sub classes.

Any instace returned by this module capable of to_string() and bind(). These
methods returns similar values as SQL::Abstract.

=head1 USAGE

=head2 SQL::OOP CLASS

This class represents SQLs or SQL snippets.

This class is extended by following classes

	SQL::OOP::ID, SQL::OOP::IDArray, SQL::OOP::Select, SQL::OOP::Insert,
	SQL::OOP::Update, SQL::OOP::Delete, SQL::OOP::Order, SQL::OOP::Dataset, 

=head3 SQL::OOP->new($str, $array_ref)
	
Constractor. It takes String and array ref.

	my $sql = SQL::OOP->new('a = ? and b = ?', [10,20]);

=head3 $instance->to_string()

This method returns the SQL string.

	$sql->to_string # 'a = ? and b = ?'

=head3 $instance->bind()

This method returns binded values in array.

	$sql->bind      # [10,20]

=head2 SQL::OOP::Array CLASS

This is an abstract class that extends SQL::OOP and is extended by following
classes.

	SQL::OOP::ID, SQL::OOP::IDArray, SQL::OOP::Select, SQL::OOP::Insert,
	SQL::OOP::Update, SQL::OOP::Delete, SQL::OOP::Order, SQL::OOP::Dataset, 

=head3 $instance->append(@elements)

This method appends elements to the instance and returns $self;

=head2 SQL::OOP::ID::Parts CLASS

This is an abstract class that repesents IDs for SQL such as table name,
schema, field name, etc.

=head2 SQL::OOP::ID CLASS

This class represents IDs such as table names, field names.

=head3 $instance->new(@ids)

=head3 $instance->as($str)

Here is some examples.

	my $id_obj = SQL::OOP::ID->new('public', 'tbl1'); 
	$id_obj->to_string; # "public"."tbl1"
	
	$id_obj->as('TMP');
	$id_obj->to_string; # "public"."tbl1" AS TMP

=head2 SQL::OOP::IDArray CLASS

This class represents ID arrays such as field lists in SELECT or table lists
in FROM clause.

=head3 $instance->new(@ids)

=head3 $instance->new(@id_objects)

Here is some examples.

	my $id_obj1 = SQL::OOP::ID->new('public', 'tbl1');
	my $id_obj2 = SQL::OOP::ID->new('public', 'tbl2');
	my $id_obj3 = SQL::OOP::ID->new('public', 'tbl3');
	
	my $id_list = SQL::OOP::IDArray->new($id_obj1, $id_obj2, $id_obj3);
	
	$id_list->to_string; # "public"."tbl1", "public"."tbl2", "public"."tbl3"

=head2 SQL::OOP::Command CLASS

This is an abstract class that represents SQL commands auch as SELECT.
The sub classes of it must have set() method for interface.

=head2 SQL::OOP::Order CLASS

This class represents ORDER clause.

=head3 SQL::OOP::Order->new();

=head3 $instance->append_asc($key);

=head3 $instance->append_desc($key);

	my $order = SQL::OOP::Order->new;
	$order->append_asc('age');
	$order->append_desc('addres');
	$order->to_string; # "age", "address" DESC

=head2 SQL::OOP::Select CLASS

This class represents SELECT commands.

=head3 SQL::OOP::Select->new(%clause)

Constractor. It takes argsuments in hash. The Hash keys are provided by
following methods. They can call either class method or instance method.
	
	ARG_FIELDS
	ARG_FROM
	ARG_WHERE
	ARG_GROUPBY
	ARG_ORDERBY
	ARG_LIMIT
	ARG_OFFSET

=head3 $instance->set(%clause)

This method resets the clause data. It takes same argument as
SQL::OOP::Select->new().

=head2 SQL::OOP::Insert CLASS

=head3 SQL::OOP::Insert->new(%clause)

Constractor. It takes argsuments in hash. The Hash keys are provided by
following methods. They can call either class method or instance method.
	
	ARG_TABLE
	ARG_DATASET
	ARG_COLUMNS
	ARG_SELECT

=head3 $instance->set(%clause)

This method resets the clause data. It takes same argument as constructor.

=head2 SQL::OOP::Update CLASS

=head3 SQL::OOP::Update->new(%clause)

Constractor. It takes argsuments in hash. The Hash keys are provided by
following methods. They can call either class method or instance method.
	
	ARG_TABLE
	ARG_DATASET
	ARG_FROM
	ARG_WHERE

=head3 $instance->set(%clause)

This method resets the clause data. It takes same argument as constructor.

=head2 SQL::OOP::Delete CLASS

=head3 SQL::OOP::Delete->new(%clause)

Constractor. It takes argsuments in hash. The Hash keys are provided by
following methods. They can call either class method or instance method.
	
	ARG_TABLE
	ARG_WHERE

=head3 $instance->set(%clause)

This method resets the clause data. It takes same argument as constructor.

=head2 SQL::OOP::Dataset CLASS

=head2 SQL::OOP::Where CLASS

=head1 EXAMPLE

Here is a complehensive example for SELECT. You also can find some examples in
test scripts.

	my $select = SQL::OOP::Select->new();
	$select->set(
		$select->ARG_FIELDS => '*',
		$select->ARG_FROM   => 'table',
		$select->ARG_WHERE  => sub {
			my $where = SQL::OOP::Where->new;
			return $where->and(
				$where->cmp('=', 'a', 1),
				$where->cmp('=', 'b', 1),
			)
		},
	);

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
