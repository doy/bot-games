#!/usr/bin/perl
package Bot::Games::Game;
use Bot::Games::OO;
use MooseX::AttributeHelpers;
use DateTime;

has help => (
    is         => 'ro',
    isa        => 'Str',
    default    => 'This game doesn\'t have any help text!',
);

has players => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push  => '_add_player',
        count => 'num_players',
    },
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
);

sub turn { "Games must provide a turn method" }
after turn => sub { shift->last_turn_time(DateTime->now) };

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;
no MooseX::AttributeHelpers;

1;
