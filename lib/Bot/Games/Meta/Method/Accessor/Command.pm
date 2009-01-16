#!/usr/bin/perl
package Bot::Games::Meta::Method::Accessor::Command;
use Moose;
extends 'Moose::Meta::Method::Accessor';
with 'Bot::Games::Meta::Role::Command';

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Moose;

1;
