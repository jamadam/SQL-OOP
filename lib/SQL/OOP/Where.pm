package SQL::OOP::Where;
use strict;
use warnings;
our $VERSION = '0.03';
	
	### ---
	### Constractor
	### ---
	sub new {
		
		my $class = shift;
		return bless {}, $class;
	}

	### ---
	### SQL::Abstract style AND factory
	### ---
	sub and_hash {
        
        my ($class, $hash_ref, $op) = @_;
		return _append_hash($class->and, $hash_ref, $op || '=');
	}
	
	### ---
	### SQL::Abstract style OR factory
	### ---
	sub or_hash {
        
        my ($class, $hash_ref, $op) = @_;
		return _append_hash($class->or, $hash_ref, $op || '=');
	}
	
	### ---
	### SQL::Abstract style AND factory backend
	### ---
	sub _append_hash {
		
		my ($obj, $hash_ref, $op) = @_;
		while (my ($key, $val) = each(%$hash_ref)) {
			$obj->append(__PACKAGE__->cmp($op || '=', $key, $val));
		}
		return $obj;
	}
	
	### ---
	### AND factory
	### ---
	sub and {
		
        my ($class, @array) = @_;
		return SQL::OOP::Array->new(@array)->set_sepa(' AND ');
	}
	
	### ---
	### OR factory
	### ---
	sub or {
		
        my ($class, @array) = @_;
		return SQL::OOP::Array->new(@array)->set_sepa(' OR ');
	}
	
	### ---
	### binary operator expression factory
	### ---
	sub cmp {
		
		my ($self, $op, $key, $val) = @_;
		if ($key && defined $val) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( $op ?), [$val]);
		}
	}
	
	### ---
	### binary operator expression factory with sub query in value
	### ---
	sub cmp_nested {
		
		my ($self, $op, $key, $val) = @_;
		if ($key && defined $val) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP::Array->new($quoted->to_string, $val)->set_sepa(" $op ");
		}
	}

	### ---
	### IS NULL factory
	### ---
	sub is_null {
		
		my ($self, $key) = @_;
		if ($key) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( IS NULL));
		}
	}

	### ---
	### IS NOT NULL factory
	### ---
	sub is_not_null {
		
		my ($self, $key) = @_;
		if ($key) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( IS NOT NULL));
		}
	}
	
	### ---
	### BETWEEN ? AND ? factory
	### ---
	sub between {
		
		my ($self, $key, $val1, $val2) = @_;
		if ($key) {
			if (defined $val1 and defined $val2) {
				my $quoted = SQL::OOP::ID->new($key)->to_string;
				my $str = $quoted. qq( BETWEEN ? AND ?);
				return SQL::OOP->new($str, [$val1, $val2]);
			} elsif (defined $val1) {
				return $self->cmp('>=', $key, $val1);
			} else {
				return $self->cmp('<=', $key, $val2);
			}
		}
	}
	
	### ---
	### IN factory
	### ---
	sub in {
		
		my ($self, $key, $array_ref) = @_;
		if ($key) {
			my $placeholder = '?, ' x scalar @$array_ref;
			$placeholder = substr($placeholder, 0, -2);
			my $quoted = SQL::OOP::ID->new($key)->to_string;
			return SQL::OOP->new("$quoted IN ($placeholder)", $array_ref);
		}
	}

1;

__END__

=head1 NAME

SQL::OOP::Where

=head1 SYNOPSIS
    
    use SQL::OOP::Where;
    
    my $where = SQL::OOP::Where->new();
    my $cond1 = $where->cmp($operator, $field, $value);
    my $cond5 = $where->is_null('some_field');
    my $cond6 = $where->is_not_null('some_field');
    my $cond4 = $where->between('some_field', 1, 2);
	my $cond3 = $where->in('some_field', [1, 2, 3]);
    my $cond2 = $where->cmp_nested($operator, $field, $select_obj);
    
    my $sql  = $cond1->to_string;
    my @bind = $cond1->bind;
    
    # combine conditions
    my $cond7 = $where->or($cond1, $cond2);
    $cond7->append($cond3);
    my $cond9 = $where->and($cond7, $where->and($cond4, $cond5));
    
    my $sql  = $cond9->to_string;
    my @bind = $cond9->bind;
    
    # SQL::Abstract style
    my %seed = (a => 'b', c => 'd');
    my $cond10 = $where->and_hash(\%seed); # default operator is '='
    my $cond11 = $where->and_hash(\%seed, "LIKE");
    my $cond12 = $where->or_hash(\%seed); # default operator is '='
    my $cond13 = $where->or_hash(\%seed, "LIKE");
    
    my $sql  = $cond13->to_string;
    my @bind = $cond13->bind;

=head1 DESCRIPTION

SQL::OOP::Where is a Factory Class which creates SQL::OOP instances for WHERE
clauses.

=head1 METHODS

=head2 new

Returns SQL::OOP::Where instance.

=head2 cmp

Generates 1 oprator expression

=head2 cmp_nested

Generates 1 oprator expression with sub query in value

=head2 in

Generates IN clause

=head2 between

Generates BETWEEN clause

=head2 is_not_null

Generates IS NOT NULL clause

=head2 is_null

Generates IS NULL clause

=head2 or

Generates OR expression in SQL::OOP::Array

=head2 or_hash

Generates OR expression in SQL::OOP::Array by hash

=head2 and

Generates AND expression in SQL::OOP::Array

=head2 and_hash

Generates AND expression in SQL::OOP::Array by hash

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
