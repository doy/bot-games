#!/usr/bin/perl
package Bot::Games::Meta::Role::Command;
use Moose::Role;

has command => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has pass_args => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

around execute => sub {
    my $orig = shift;
    my $self = shift;
    return $self->pass_args ? $orig->$self(@_) : $orig->$self();
};

no Moose::Role;

1;
