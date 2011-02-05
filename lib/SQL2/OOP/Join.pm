package SQL::OOP::Join;
use strict;
use warnings;
use SQL::OOP;
use base qw(SQL::OOP::Command);

	sub ARG_DIRECTION()		{1} ## no critic
	sub ARG_TABLE1()		{2} ## no critic
	sub ARG_TABLE2()		{3} ## no critic
	sub ARG_ON()			{4} ## no critic
	
	sub ARG_DIRECTION_INNER()	{'INNER'} ## no critic
	sub ARG_DIRECTION_LEFT()	{'LEFT'} ## no critic
	sub ARG_DIRECTION_RIGHT()	{'RIGHT'} ## no critic
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
		return [ARG_TABLE1, ARG_DIRECTION, ARG_TABLE2, ARG_ON];
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
		my $self= shift;
		return {
			ARG_TABLE1() 		=> '',
			ARG_DIRECTION()		=> '',
			ARG_TABLE2()		=> 'JOIN',
			ARG_ON()			=> 'ON',
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

return 1;
