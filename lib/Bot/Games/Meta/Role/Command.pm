#!/usr/bin/perl
package Bot::Games::Meta::Role::Command;
use Moose::Role;

has pass_args => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose::Role;

1;
