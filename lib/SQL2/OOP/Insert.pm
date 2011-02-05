package SQL::OOP::Insert;
use strict;
use warnings;
use SQL::OOP::Dataset;
use base qw(SQL::OOP::Command);
	
	sub ARG_TABLE()		{1} ## no critic
	sub ARG_DATASET() 	{2} ## no critic
	sub ARG_COLUMNS() 	{3} ## no critic
	sub ARG_SELECT()	{4} ## no critic
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
		return [ARG_TABLE, ARG_DATASET, ARG_COLUMNS, ARG_SELECT];
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
		return {
			ARG_TABLE()		=> 'INSERT INTO',
			ARG_DATASET() 	=> '',
			ARG_COLUMNS()	=> '',
			ARG_SELECT() 	=> '',
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
		
		my ($self) = @_;
		if ($self->{array}->[1]) {
			$self->{array}->[1]->generate(SQL::OOP::Dataset->MODE_INSERT);
		}
		return shift->SUPER::to_string(@_);
	}
	
	### ---
	### SQLスニペットを得る(IDEの補完候補検出用)
	### ---
	sub bind {
		
		return shift->SUPER::bind(@_);
	}

return 1;
