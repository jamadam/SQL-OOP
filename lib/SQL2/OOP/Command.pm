package SQL::OOP::Command;
use strict;
use warnings;
use SQL::OOP;
use base qw(SQL::OOP::Array);
	
	### ---
	### コンストラクタ
	### ---
	sub new {
		
		my ($class, %args) = (@_);
		my $self = bless {
			gen => undef,
			array => undef,
        }, $class;
		
		$self->set(%args);
		return $self;
	}
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
	}
	
	### ---
	### トークンの名称をキーとし、連番を値とした配列を返す
	### ---
	sub keys_to_idx {
		
		my ($self) = (@_);
		my $out = ();
		my $idx = 0;
		foreach my $key (@{$self->KEYS}) {
			$out->{$key} = $idx;
			$idx++;
		}
		return $out;
	}
	
	### ---
	### 要素を設定
	### ---
	sub set {
		
		my ($self, %args) = @_;
		$self->_init_gen;
		my $tokens = $self->keys_to_idx;
		foreach my $key (keys %args) {
			my $idx = $tokens->{$key};
			$self->{array}->[$idx] = SQL::OOP->new($args{$key});
		}
		
		return $self;
	}
	
	### ---
	### SQLスニペットを生成
	### ---
	sub generate {
		
		my ($self) = @_;
		$self->{gen} = '';
		my $prefix = $self->PREFIXES;
		my $tokens = $self->keys_to_idx;
		for (my $idx = 0; $idx < @{$self->KEYS}; $idx++) {
			if (my $obj = $self->{array}->[$idx]) {
				if (my $a = $obj->to_string) {
					if ($obj->isa(__PACKAGE__)) {
						$a = '('. $a. ')';
					}
					my $name = $self->KEYS->[$idx];
					if ($prefix->{$name}) {
						$self->{gen} .= ' '. $prefix->{$name}. ' '. $a;
					} else {
						$self->{gen} .= ' '. $a;
					}
				}
			}
		}
		
		$self->{gen} =~ s/^ //;
	}

return 1;
