package SQL::OOP::Update;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use SQL::OOP::Dataset;
use base qw(SQL::OOP::Command);
	
	sub ARG_TABLE()		{1} ## no critic
	sub ARG_DATASET()	{2} ## no critic
	sub ARG_FROM()		{3} ## no critic
	sub ARG_WHERE()		{4} ## no critic
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
		return [ARG_TABLE, ARG_DATASET, ARG_FROM, ARG_WHERE];
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
		return {
			ARG_TABLE()	 	=> 'UPDATE',
			ARG_DATASET() 	=> 'SET',
			ARG_FROM() 		=> 'FROM',
			ARG_WHERE() 	=> 'WHERE',
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
	### SQLスニペットを得る
	### ---
	sub to_string {
		
		my ($self) = @_;
		$self->{array}->[1]->generate(SQL::OOP::Dataset->MODE_UPDATE);
		return shift->SUPER::to_string(@_);
	}
	
	### ---
	### SQLスニペットを得る(IDEの補完候補検出用)
	### ---
	sub bind {
		
		return shift->SUPER::bind(@_);
	}

return 1;
