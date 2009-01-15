#!/usr/bin/perl
package Bot::Games::Game::Xghost;
use Bot::Games::OO;
use Games::Word qw/is_substring/;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "xghost help",
);

command valid_move => sub {
    my $self = shift;
    my ($move) = @_;
    return is_substring($self->state, uc($move))
        && length($self->state) + 1 == length($move);
};

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
