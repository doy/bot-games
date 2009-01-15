#!/usr/bin/perl
package Bot::Games::Game::Ghost;
use Bot::Games::OO;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "ghost help",
);

command valid_move => {
    my $self = shift;
    my ($move) = @_;
    return uc(substr($move, 0, -1)) eq $self->state;
};

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
