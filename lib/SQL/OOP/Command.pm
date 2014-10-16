package SQL::OOP::Command;
use strict;
use warnings;
use SQL::OOP::Base;
use SQL::OOP::ID;
use SQL::OOP::IDArray;
use base qw(SQL::OOP::Array);

### ---
### Constructor
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
### Get Names of set arguments in array ref
### ---
sub KEYS {
    
}

### ---
### Get prefixes for each clause in hash ref
### ---
sub PREFIXES {
    
}

### ---
### Get clause names and array index in array
### ---
sub keys_to_idx {
    my ($self) = (@_);
    my $out = ();
    my $idx = 0;
    $out->{$_} = $idx++ foreach (@{$self->KEYS});
    return $out;
}

### ---
### Set elements
### ---
sub set {
    my ($self, %args) = @_;
    $self->_init_gen;
    my $t = $self->keys_to_idx;
    $self->{array}->[$t->{$_}] = SQL::OOP::Base->new($args{$_}) for (keys %args);
    return $self;
}

### ---
### Genereate SQL snippet
### ---
sub generate {
    my ($self) = @_;
    $self->{gen} = '';
    my $prefix = $self->PREFIXES;
    my $tokens = $self->keys_to_idx;
    for (my $idx = 0; $idx < @{$self->KEYS}; $idx++) {
        if (my $obj = $self->{array}->[$idx]) {
            if (my $a = $obj->to_string) {
                $a = '('. $a. ')' if ($obj->isa(__PACKAGE__));
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

### ---
### retrieve partial object out of command
### ---
sub retrieve {
    my ($self, $key) = @_;
    return $self->{array}->[$self->keys_to_idx->{$key}];
}

1;

__END__

=head1 NAME

SQL::OOP::Command

=head1 SYNOPSIS

See document of subclasses.

=head1 DESCRIPTION

SQL::OOP::Command is an abstract class which represents SQL commands such as
SELECT, INSERT, UPDATE etc.

=head1 METHODS

=head2 generate

=head2 new

Constructer

=head2 set

=head2 retrieve

Retrieves command parts so that you can recycle them or even modify them.

    sub append_field {
        my ($select, $new_field) = @_;
        $select->set(
            fields => SQL::OOP->id_array(
                $select->retrieve('fields'),
                $new_field,
            ),
        );
        return $select;
    }
    
    append_field($select, 'col34');

=head1 Constants

=head2 KEYS

Returns well ordered key array. The method must be overridden by sub classes.

=head2 PREFIXES

Returns prefixes for each clause. The method must be overridden by sub classes.

=head2 keys_to_idx

Get clause names and array index in array

=head1 SEE ALSO

=cut
