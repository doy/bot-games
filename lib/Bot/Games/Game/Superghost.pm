#!/usr/bin/perl
package Bot::Games::Game::Superghost;
use Bot::Games::OO;
extends 'Bot::Games::Game::Ghost';

has '+help' => (
    default => "superghost help",
);

command valid_move => sub {
    my $self = shift;
    my ($move) = @_;
    return uc(substr($move, 0, -1)) eq $self->state
        || uc(substr($move, 1))     eq $self->state;
};

command valid_word_from_state => sub {
    my $self = shift;
    my ($word) = @_;
    my $state = $self->state;
    return uc($word) =~ /\Q$state\E/;
};

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
