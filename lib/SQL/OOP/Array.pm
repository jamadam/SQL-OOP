### ---
### Array of SQL snippets
### ---
package SQL::OOP::Array;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(SQL::OOP::Base);

### ---
### Constructor
### ---
sub new {
    my ($class, @array) = @_;
    my $self = bless {
        sepa    => ' ',
        gen     => undef,
        array   => undef,
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
    if (ref $array[0] && ref $array[0] eq 'ARRAY') {
        @array = @{$array[0]};
    }
    foreach my $elem (@array) {
        push(@{$self->{array}}, SQL::OOP::Base->new($elem)) if ($elem);
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
            $_->to_string;
        }
    } @{$self->{array}};
    $self->{gen} = join($self->{sepa}, grep {$_} @array);
    
    return $self;
}

### ---
### fix generated string in list context
### ---
sub fix_element_in_list_context {
    my ($self, $obj) = @_;
    return '('. $obj->to_string. ')' if ($obj->isa(__PACKAGE__));
    return $obj->to_string;
}

### ---
### Get binded values in array
### ---
sub bind {
    my $self = shift;
    my @out = map {
        my @a = $_->bind if ($_);
        @a;
    } @{$self->{array}};
    return @out if (wantarray);
    return scalar @out;
}

sub values {
    my $self = shift;
    return @{$self->{array}};
}

1;

__END__

=head1 NAME

SQL::OOP::Array - An Abstract class for any combination of snippets

=head1 SYNOPSIS
    
    my $array = SQL::OOP::Array->new(@elements);
    my $sql  = $array->to_string;
    my @bind = $array->bind;

=head1 DESCRIPTION

This is an abstract class which represents array of SQL snippets.

=head1 METHODS

This class inherits all methods from SQL::OOP::Base. Some of them is overridden.

=head2 SQL::OOP::Array->new(@elements)

Constructor. Since this class is an abstract, you may not have to call this
directly.

    SQL::OOP::Array->new('elem1', 'elem2', 'elem3'); # elem1 elem2 elem3

Arguments can be SQL::OOP::Base instances.

    my $sql = SQL::OOP->new;
    my $elem1 = $sql->base('elem1');
    my $elem2 = $sql->base('elem2');
    my $elem3 = $sql->base('elem3');
    
    SQL::OOP::Array->new($elem1, $elem2, $elem3); # elem1 elem2 elem3

=head2 $instance->append(@elements)

This method appends elements to the instance and returns $self. This method
takes same arguments as new constructor.

=head2 $instance->set_sepa($string)

This sets separator string such as ' AND ' or ' OR ' for where clause, comma for
identifiers.

=head2 $instance->bind;

This method corrects all children's bind values and returns all together.

=head2 $instance->generate;

This method generates SQL. This is called inside to_string so don't call it
directly. This method internally corrects all children's to_string results and
join them with separator.

=head2 $instance->values;

Retrieve values into array.

=head2 $instance->fix_element_in_list_context

Finalizing method on Stringify. For internal use. This is internally called by
generate method to parenthesizes the SQL on list context.

=head1 SEE ALSO

=cut
