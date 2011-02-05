package SQL::OOP::Where;
use strict;
use warnings;
our $VERSION = '0.03';
	
	### ---
	### コンストラクタ
	### ---
	sub new {
		
		my $class = shift;
		return bless {}, $class;
	}

	### ---
	### and条件をハッシュリファレンスで一括指定
	### ---
	sub and_hash {
        
        my ($class, $hash_ref, $op) = @_;
		return _append_hash($class->and, $hash_ref, $op || '=');
	}
	
	### ---
	### or条件をハッシュリファレンスで一括指定
	### ---
	sub or_hash {
        
        my ($class, $hash_ref, $op) = @_;
		return _append_hash($class->or, $hash_ref, $op || '=');
	}
	
	### ---
	### 条件をハッシュリファレンスで一括指定
	### ---
	sub _append_hash {
		
		my ($obj, $hash_ref, $op) = @_;
		while (my ($key, $val) = each(%$hash_ref)) {
			$obj->append(__PACKAGE__->cmp($op || '=', $key, $val));
		}
		return $obj;
	}
	
	### ---
	### AND配列インスタンス
	### ---
	sub and {
		
        my ($class, @array) = @_;
		return SQL::OOP::Array->new(@array)->set_sepa(' AND ');
	}
	
	### ---
	### OR配列インスタンス
	### ---
	sub or {
		
        my ($class, @array) = @_;
		return SQL::OOP::Array->new(@array)->set_sepa(' OR ');
	}
	
	sub cmp_nested {
		
		my ($self, $op, $key, $val) = @_;
		if ($key && defined $val) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP::Array->new($quoted->to_string, $val)->set_sepa(" $op ");
		}
	}
	
	### ---
	### 2項演算子比較
	### ---
	sub cmp {
		
		my ($self, $op, $key, $val) = @_;
		if ($key && defined $val) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( $op ?), [$val]);
		}
	}

	### ---
	### IS NULL
	### ---
	sub is_null {
		
		my ($self, $key) = @_;
		if ($key) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( IS NULL));
		}
	}

	### ---
	### IS NULL
	### ---
	sub is_not_null {
		
		my ($self, $key) = @_;
		if ($key) {
			my $quoted = SQL::OOP::ID->new($key);
			return SQL::OOP->new($quoted->to_string. qq( IS NOT NULL));
		}
	}
	
	### ---
	### BETWEEN ? AND ?
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
	
	sub in {
		
		my ($self, $key, $array_ref) = @_;
		if ($key) {
			my $placeholder = '?, ' x scalar @$array_ref;
			$placeholder = substr($placeholder, 0, -2);
			my $quoted = SQL::OOP::ID->new($key)->to_string;
			return SQL::OOP->new("$quoted IN ($placeholder)", $array_ref);
		}
	}

return 1;
