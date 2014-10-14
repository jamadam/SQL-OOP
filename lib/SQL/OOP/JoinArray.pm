package SQL::OOP::JoinArray;
use strict;
use warnings;
use SQL::OOP::Base;
use base qw(SQL::OOP::Array);

### ---
### fix generated string in list context
### ---
sub fix_element_in_list_context {
    my ($self, $obj) = @_;
    return $obj->to_string;
}

1;

__END__

=head1 NAME

SQL::OOP::JoinArray [EXPERIMENTAL]

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 SQL::OOP::JoinArray->new

=head1 SEE ALSO

=cut
