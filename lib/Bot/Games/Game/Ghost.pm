#!/usr/bin/perl
package Bot::Games::Game::Ghost;
use Moose;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "ghost help",
);

sub valid_move {
    my $self = shift;
    my ($move) = @_;
    return uc(substr($move, 0, -1)) eq $self->state;
}

1;
