#!/usr/bin/perl
package Bot::Games::Meta::Role::Command;
use Moose::Role;

has pass_args => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

no Moose::Role;

1;
