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
    isa        => 'Bool',
    command    => 1,
);

sub turn {
    my $turn = inner();
    return $turn if defined($turn);
    return "Games must provide a turn method";
}
after turn => sub { shift->last_turn_time(DateTime->now) };

command cmdlist => sub {
    my $self = shift;
    my @commands;
    for my $method ($self->meta->get_all_methods) {
        push @commands, $method->name
            if $method->meta->can('does_role')
            && $method->meta->does_role('Bot::Games::Meta::Role::Command');
    }
    return join ' ', map { '-' . $_ } @commands;
}, needs_init => 0;

# this happens in Bot::Games, since we want to add the say method from there
#__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;
no MooseX::AttributeHelpers;

1;
