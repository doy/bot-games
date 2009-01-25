#!/usr/bin/perl
package Bot::Games::Meta::Role::Command;
use Moose::Role;

has pass_args => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

has needs_init => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

around execute => sub {
    my $orig = shift;
    my $self = shift;
    return $self->pass_args ? $self->$orig(@_) : $self->$orig();
};

no Moose::Role;

1;
