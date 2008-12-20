#!/usr/bin/perl
package Bot::Games::Game::Superghost;
use Moose;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "superghost help",
);

sub valid_move {
    my $self = shift;
    my ($move) = @_;
    return uc(substr($move, 0, -1)) eq $self->state
        || uc(substr($move, 1))     eq $self->state;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
