#!/usr/bin/perl
package Bot::Games::Game;
use Bot::Games::OO;
use MooseX::AttributeHelpers;
use DateTime;

has help => (
    is         => 'ro',
    isa        => 'Str',
    default    => 'This game doesn\'t have any help text!',
    command    => 1,
    needs_init => 0,
);

has players => (
    metaclass  => 'Collection::Array',
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push  => 'add_player',
        count => 'num_players',
    },
    command    => 1,
);
command 'num_players';

has start_time => (
    is         => 'ro',
    isa        => 'DateTime',
    default    => sub { DateTime->now },
    command    => 1,
);

has last_turn_time => (
    is         => 'rw',
    isa        => 'DateTime',
    command    => 1,
);

has is_over => (
    is         => 'rw',
    isa        => 'Str',
    command    => 1,
);

sub turn {
    my $turn = inner();
    return $turn if defined($turn);
    return "Games must provide a turn method";
}
after turn => sub { shift->last_turn_time(DateTime->now) };

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;
no MooseX::AttributeHelpers;

1;
