#!/usr/bin/perl
package Bot::Games;
use Moose;
use Module::Pluggable
    search_path => 'Bot::Games::Game',
    except      => ['Bot::Games::Ghostlike'],
    require     => 1,
    sub_name    => 'games';
extends 'Bot::BasicBot';

has prefix => (
    is       => 'ro',
    isa      => 'Str',
    default  => '!',
);

has active_games => (
    is      => 'ro',
    isa     => 'HashRef[Bot::Games::Game]',
    default => sub { {} },
);

sub said {
    my $self = shift;
    my $args = @_;
    my $prefix = $self->prefix;

    return if $args->{channel} eq 'msg';
    return unless $args->{body} =~ /^$prefix(\w+)\s+(.*)/;
    my ($game_name, $action) = ($1, $2);
    return unless $self->valid_game($game_name);

    my $game = $self->games->{$game_name};
    $game = $self->active_games->{$game_name}
          = $self->game_package($game_name)->new
        unless defined $game;

    if ($action =~ /-(\w+)\s*(.*)/) {
        my ($action, $arg) = ($1, $2);
        return "$action is private in $game_name"
            if $action =~ s/^_//;
        return $game->$action
            if $game->meta->has_attribute($action);
        return $game->$action($args->{who}, $arg)
            if $game->can($action);
        return "Unknown command $action for game $game_name.";
    }

    my $output = $game->turn($args->{who}, $action);
    if (my $end_msg = $game->is_over) {
        $self->say(%$args, body => $output);
        $output = $end_msg;
        delete $self->active_games->{$game_name};
    }
    return $output;
}

sub valid_game {
    my $self = shift;
    my ($name) = @_;
    my $package = $self->game_package($name);
    return (grep { $package eq $_ } $self->games) ? 1 : 0;
}

sub game_package {
    my $self = shift;
    my ($name) = @_;
    return 'Bot::Games::' . ucfirst($name);
}

1;
