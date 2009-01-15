#!/usr/bin/perl
package Bot::Games::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

use Bot::Games::Meta::Attribute;

around initialize => sub {
    my $orig = shift;
    my $self = shift;
    my $pkg  = shift;

    $self->$orig($pkg,
        attribute_metaclass => 'Bot::Games::Meta::Attribute',
        @_,
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
