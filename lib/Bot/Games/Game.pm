#!/usr/bin/perl
package Bot::Games::Game;
use Moose;
use DateTime;

has players => (
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    default    => sub { [] },
);

has start_time => (
    is         => 'ro',
    isa        => 'DateTime',
    default    => sub { DateTime->now },
);

has last_turn_time => (
    is         => 'rw',
    isa        => 'DateTime',
);

has is_over => (
    is         => 'rw',
    isa        => 'Str',
    default    => '',
);

sub turn { "Games must provide a turn method" }
after turn => sub { shift->last_turn_time(DateTime->now) };

1;
