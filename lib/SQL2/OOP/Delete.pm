package SQL::OOP::Delete;
use strict;
use warnings;
use SQL::OOP;
use SQL::OOP::Where;
use base qw(SQL::OOP::Command);

	sub ARG_TABLE() {1} ## no critic
	sub ARG_WHERE() {2} ## no critic
	
	### ---
	### トークン毎の設定引数の名前の配列リファレンスを返す
	### ---
	sub KEYS {
		
		return [ARG_TABLE, ARG_WHERE];
	}
	
	### ---
	### トークン毎のプレフィックスのハッシュリファレンスを返す
	### ---
	sub PREFIXES {
		
		return {
			ARG_TABLE() => 'DELETE FROM',
			ARG_WHERE() => 'WHERE',
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
