#!/usr/bin/perl
package Bot::Games::Meta::Method::Command;
use Moose;
extends 'Moose::Meta::Method';
with 'Bot::Games::Meta::Role::Command';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
