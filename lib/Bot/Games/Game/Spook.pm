#!/usr/bin/perl
package Bot::Games::Game::Spook;
use Moose;
use Games::Word qw/is_subpermutation/;
extends 'Bot::Games::Game::Ghostlike';

has '+help' => (
    default => "spook help",
);

sub valid_move {
    my $self = shift;
    my ($move) = @_;
    return is_subpermutation($self->state, uc($move))
        && length($self->state) + 1 == length($move);
}

sub valid_word_from_state {
    my $self = shift;
    my ($word) = @_;
    $word = uc join '', sort split(//, $word);
    my $state = join '', sort split(//, $self->state);
    return $word eq $state;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
