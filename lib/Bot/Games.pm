#!/usr/bin/perl
package Bot::Games;
use Moose;
use Module::Pluggable
    search_path => 'Bot::Games::Game',
    except      => ['Bot::Games::Game::Ghostlike'],
    require     => 1,
    sub_name    => 'games';
extends 'Bot::BasicBot';

has prefix => (
    is       => 'rw',
    isa      => 'Str',
    lazy     => 1,
    default  => '!',
);

has active_games => (
    is      => 'ro',
    isa     => 'HashRef[Bot::Games::Game]',
    lazy    => 1,
    default => sub { {} },
);

around new => sub {
    my $orig = shift;
    my $class = shift;
    my %args = @_;
    my $prefix = delete $args{prefix};
    my $self = $class->$orig(%args);
    $self->prefix($prefix) if $prefix;
    return $self;
};

sub said {
    my $self = shift;
    my ($args) = @_;
    my $prefix = $self->prefix;

    return if $args->{channel} eq 'msg';
    return unless $args->{body} =~ /^$prefix(\w+)(?:\s+(.*))?/;
    my ($game_name, $action) = ($1, $2);
    return unless $self->valid_game($game_name);

    my $game = $self->active_games->{$game_name};
    if (!defined $game || !defined $action) {
        $game = $self->game_package($game_name)->new;
        $self->active_games->{$game_name} = $game;
        my $output = $game->_init($args->{who});
        $self->say(%$args, body => $self->_format($output))
            if defined $output;
    }

    return unless defined $action;

    my $output;
    if ($action =~ /^-(\w+)\s*(.*)/) {
        my ($action, $arg) = ($1, $2);
        if ($action =~ s/^_//) {
            $output = "$action is private in $game_name";
        }
        elsif ($game->meta->find_attribute_by_name($action)) {
            $output = $game->$action();
        }
        elsif ($game->can($action)) {
            $output = $game->$action($arg, {player => $args->{who}});
        }
        else {
            $output = "Unknown command $action for game $game_name";
        }
    }
    else {
        $output = $game->turn($args->{who}, $action);
    }

    if (my $end_msg = $game->is_over) {
        $self->say(%$args, body => $self->_format($output))
            if defined $output;
        $output = $end_msg;
        delete $self->active_games->{$game_name};
    }
    return $output;
}
around said => sub {
    my $orig = shift;
    my $self = shift;
    return $self->_format($self->$orig(@_));
};

sub valid_game {
    my $self = shift;
    my ($name) = @_;
    my $package = $self->game_package($name);
    return (grep { $package eq $_ } $self->games) ? 1 : 0;
}

sub game_package {
    my $self = shift;
    my ($name) = @_;
    return 'Bot::Games::Game::' . ucfirst($name);
}

sub _format {
    my $self = shift;
    my ($to_print) = @_;
    if (blessed $to_print) {
        $to_print = "$to_print";
    }
    elsif (ref($to_print) && ref($to_print) eq 'ARRAY') {
        $to_print = join ', ', @$to_print;
    }
    elsif (!$to_print) {
        $to_print = '0';
    }
    return $to_print;
}

1;
