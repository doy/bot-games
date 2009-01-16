#!/usr/bin/perl
package Bot::Games::Meta::Attribute;
use Moose;
extends 'Moose::Meta::Attribute';

use Bot::Games::Meta::Method::Accessor::Command;

has command => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around accessor_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    return $self->command ? 'Bot::Games::Meta::Method::Accessor::Command'
                          : $self->$orig(@_);
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Moose;

1;
