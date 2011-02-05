package SQL::OOP::Select;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use base qw(SQL::OOP::Command);

	sub ARG_FIELDS()	{1} ## no critic
	sub ARG_FROM()		{2} ## no critic
	sub ARG_WHERE()		{3} ## no critic
	sub ARG_GROUPBY()	{4} ## no critic
	sub ARG_ORDERBY()	{5} ## no critic
	sub ARG_LIMIT()		{6} ## no critic
	sub ARG_OFFSET()	{7} ## no critic
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
		return
		[ARG_FIELDS, ARG_FROM, ARG_WHERE,
		 ARG_GROUPBY, ARG_ORDERBY, ARG_LIMIT, ARG_OFFSET];
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
		return {
			ARG_FIELDS() 	=> 'SELECT',
			ARG_FROM() 		=> 'FROM',
			ARG_WHERE()		=> 'WHERE',
			ARG_GROUPBY()	=> 'GROUP BY',
			ARG_ORDERBY() 	=> 'ORDER BY',
			ARG_LIMIT()		=> 'LIMIT',
			ARG_OFFSET()	=> 'OFFSET',
		}
	}
	
	### ---
	### コンストラクタ(IDEの補完候補検出用)
	### ---
	sub new {
		
		my ($class, %hash) = @_;
		return $class->SUPER::new(%hash);
	}
	
	### ---
	### トークンを追加(IDEの補完候補検出用)
	### ---
	sub set {
		
		my ($class, %hash) = @_;
		return $class->SUPER::set(%hash);
	}
	
	### ---
	### SQLスニペットを得る(IDEの補完候補検出用)
	### ---
	sub to_string {
		
		return shift->SUPER::to_string(@_);
	}
	
	### ---
	### SQLスニペットを得る(IDEの補完候補検出用)
	### ---
	sub bind {
		
		return shift->SUPER::bind(@_);
	}

package SQL::OOP::Order;
use SQL::OOP;
use base qw(SQL::OOP::Array);
	
	### ---
	### コンストラクタ
	### ---
	sub new {
		
		my ($class, @array) = @_;
        return $class->SUPER::new(@array)->set_sepa(', ');
	}
    
    sub abstract {
        
        my ($class, $array_ref) = @_;
        my $self = $class->SUPER::new()->set_sepa(', ');
        foreach my $rec_ref (@{$array_ref}) {
            if ($rec_ref->[1]) {
                $self->append_desc($rec_ref->[0]);
            } else {
                $self->append_asc($rec_ref->[0]);
            }
        }
        return $self;
    }
	
	### ---
	### SQL::OOP::Order::Expressionインスタンスを得る(ASC)
	### ---
	sub new_asc {
		
		my ($class_or_obj, $key) = @_;
		return SQL::OOP::Order::Expression->new($key);
	}
	
	### ---
	### SQL::OOP::Order::Expressionインスタンスを得る(DESC)
	### ---
	sub new_desc {
		
		my ($class_or_obj, $key) = @_;
		return SQL::OOP::Order::Expression->new_desc($key);
	}
	
	### ---
	### 要素の追加(ASC)
	### ---
	sub append_asc {
		
		my ($self, $key) = @_;
		$self->_init_gen;
		push(@{$self->{array}}, SQL::OOP::Order::Expression->new($key));
		return $self;
	}
	
	### ---
	### 要素の追加(DESC)
	### ---
	sub append_desc {
		
		my ($self, $key) = @_;
		$self->_init_gen;
		push(@{$self->{array}}, SQL::OOP::Order::Expression->new_desc($key));
		return $self;
	}

package SQL::OOP::Order::Expression;
use strict;
use warnings;
use base qw(SQL::OOP);

	### ---
	### コンストラクタ
	### ---
	sub new {
		
		my ($class, $key) = @_;
		if ($key) {
			return $class->SUPER::new(SQL::OOP::ID->quote($key));
		}
	}
	
	### ---
	### コンストラクタ
	### ---
	sub new_desc {
		
		my ($class, $key) = @_;
		if ($key) {
			return $class->SUPER::new(SQL::OOP::ID->quote($key). " DESC");
		}
	}

return 1;
