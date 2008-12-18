#!/usr/bin/perl
use strict;
use warnings;
package Bot::Games::Game::Ghostlike;
use Moose;
use Games::Word::Wordlist;
extends 'Bot::Games::Game';

has current_player => (
    is         => 'rw',
    isa        => 'Str',
    predicate  => '_has_current_player',
);

has players_fixed => (
    is         => 'rw',
    isa        => 'Bool',
    default    => 0,
);

has state => (
    is         => 'rw',
    isa        => 'Str',
    default    => '',
);

has challenger => (
    is         => 'rw',
    isa        => 'Str',
    predicate  => 'has_challenger',
);

has _wordlist => (
    is         => 'ro',
    isa        => 'Games::Word::Wordlist',
    default    => sub { Games::Word::Wordlist->new('/usr/share/dict/words') },
    handles    => {
        _valid_word => 'is_word',
    },
);

around state => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig unless @_;
    my ($state) = @_;
    $state = uc $state;
    return $self->$orig($state);
};

sub turn {
    my $self = shift;
    my ($player, $state) = @_;

    if ($self->_current_player_index == 0
     && !$self->players_fixed
     && !grep { $player eq $_ } $self->players) {
        $self->_add_player($player);
        $self->current_player($player);
    }

    return "It's " . $self->current_player . "'s turn!"
        if $player ne $self->current_player;
    return "You must respond to " . $self->challenger . "'s challenge!"
        if $self->has_challenger;
    return "$state isn't a valid move!"
        unless $self->valid_move($state);

    $self->current_player($self->next_player);
    return $self->state($state);
}

sub challenge {
    my $self = shift;
    my ($player, $word) = @_;
    return "It's " . $self->current_player . "'s turn!"
        if $player ne $self->current_player;
    my $prev = $self->previous_player;
    my $challenger = $self->has_challenger ? $self->challenger : $player;
    if ($word) {
        if (!$self->valid_word_from_state($word)) {
            return "$word is not valid for state " . $self->state . "!";
        }
        elsif ($self->_valid_word($word)) {
            $self->is_over("$word is a word! $challenger wins!");
            return;
        }
        else {
            $self->is_over("$word is not a word. $challenger loses!");
            return;
        }
    }
    else {
        $self->challenger($player);
        $self->current_player($prev);
        return "$player is challenging $prev!";
    }
}

sub previous_player {
    my $self = shift;
    return unless $self->_has_current_player;
    return $self->players->[$self->_current_player_index - 1];
}

sub next_player {
    my $self = shift;
    return unless $self->_has_current_player;
    return $self->players->[($self->_current_player_index + 1) % $self->num_players];
}

sub valid_move { 1 }

sub valid_word_from_state {
    my $self = shift;
    my ($word) = @_;
    return $word eq $self->state;
}

sub _current_player_index {
    my $self = shift;
    for (0..($self->num_players - 1)) {
        return $_ if $self->current_player eq $self->players->[$_];
    }
    return 0;
}

1;
