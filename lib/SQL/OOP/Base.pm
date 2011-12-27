package SQL::OOP::Base;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use base qw(Class::Data::Inheritable);
use 5.005;
    
    ### ---
    ### default quote character
    ### ---
    __PACKAGE__->mk_classdata(quote_char => q("));
    
    ### ---
    ### escape_code_ref for col names
    ### ---
    __PACKAGE__->mk_classdata(escape_code_ref => sub {
        my ($str, $quote_char) = @_;
        $str =~ s{$quote_char}{$quote_char$quote_char}g;
        return $str;
    });
    
    ### ---
    ### Constructor
    ### ---
    sub new {
        
        my ($class, $str, $bind_ref) = @_;
        if (ref $str && (ref($str) eq 'CODE')) {
            $str = $str->();
        }
        if (blessed($str) && $str->isa(__PACKAGE__)) {
            return $str;
        } elsif ($str) {
            if ($bind_ref && ! ref $bind_ref) {
                die '$bind_ref must be an Array ref';
            }
            return bless {
                str     => $str,
                gen     => undef,
                bind    => ($bind_ref || [])
            }, $class;
        }
        return;
    }
    
    ### ---
    ### Get SQL snippet
    ### ---
    sub to_string {
        
        my ($self, $prefix) = @_;
        if (! defined $self->{gen}) {
            $self->generate;
        }
        if ($self->{gen} && $prefix) {
            return $prefix. ' '. $self->{gen};
        } else {
            return $self->{gen};
        }
    }
    
    ### ---
    ### Get SQL snippet with values embedded [EXPERIMENTAL]
    ### ---
    sub to_string_embedded {
        
        my ($self, $quote_with) = @_;
        $quote_with ||= q{'};
        my $format = $self->to_string;
        $format =~ s{\?}{%s}g;
        return
        sprintf($format, map {$self->quote($_, $quote_with)} @{[$self->bind]});
    }
    
    ### ---
    ### Get binded values in array
    ### ---
    sub bind {
        
        my ($self) = @_;
        return @{$self->{bind} || []} if (wantarray);
        return scalar @{$self->{bind} || []};
    }
    
    ### ---
    ### initialize generated SQL
    ### ---
    sub _init_gen {
        
        my ($self) = @_;
        $self->{gen} = undef;
    }

    ### ---
    ### Generate SQL snippet
    ### ---
    sub generate {
        
        my ($self) = @_;
        $self->{gen} = $self->{str} || '';
        return $self;
    }
    
    ### ---
    ### quote
    ### ---
    sub quote {
        
        my ($class, $val, $with) = @_;
        if (! $with) {
            if (blessed($class)) {
                $class = blessed($class);
            }
            $with = $class->quote_char;
        }
        if (defined $val) {
            $val = $class->escape_code_ref->($val, $with);
            return $with. $val. $with;
        } else {
            return undef;
        }
    }

1;

__END__

=head1 NAME

SQL::OOP::Base - SQL Generator base class

=head1 SYNOPSIS
    
    my $sql = SQL::OOP::Base->new('field1 = ?', [1]);
    
    my $sql  = $select->to_string;
    my @bind = $select->bind;

=head1 DESCRIPTION

This class represents SQLs or SQL snippets.

=head2 SQL::OOP::Base->new($str, $array_ref)
    
Constructor. It takes String and array ref.

    my $sql = SQL::OOP::Base->new('a = ? and b = ?', [10,20]);

$str can be a code ref. If so, the code invokes immediately inside constructor.

    my $sql = SQL::OOP::Base->new(sub {return 'a = ? and b = ?'}, [10,20]);

=head2 SQL::OOP::Base->quote_char($quote_char)

=head2 SQL::OOP::Base->escape_code_ref($code_ref)

=head2 $instance->to_string()

This method returns the SQL string.

    $sql->to_string # 'a = ? and b = ?'

=head2 $instance->to_string_embedded() [EXPERIMENTAL]

This method returns the SQL string with binded values embedded. This method aimed
at use of debugging.

    $sql->to_string_embedded # a = 'value' and b = 'value'

=head2 $instance->bind()

This method returns binded values in array.

    $sql->bind      # [10,20]

=head2 $instance->generate()

=head2 SQL::OOP::Base->quote()

=head1 SEE ALSO

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
