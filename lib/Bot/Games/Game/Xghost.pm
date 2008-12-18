#!/usr/bin/perl
package Bot::Games::Game::Xghost;
use Moose;
use Games::Word qw/is_substring/;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "xghost help",
);

sub valid_move {
    my $self = shift;
    my ($move) = @_;
    return is_substring($self->state, $move)
        && length($self->state) + 1 == length($move);
}

1;
