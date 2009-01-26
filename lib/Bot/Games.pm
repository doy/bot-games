#!/usr/bin/perl
package Bot::Games;
use Bot::Games::OO;
use Module::Pluggable
    search_path => 'Bot::Games::Game',
    except      => ['Bot::Games::Game::Ghostlike'],
    sub_name    => 'games';
extends 'Bot::BasicBot', 'Moose::Object';
around new => sub {
    my $orig = shift;
    my $class = shift;
    my $self = $class->$orig(@_);
    $self->BUILDALL({@_});
    return $self;
};

has prefix => (
    is       => 'rw',
    isa      => 'Str',
    default  => '!',
);

has active_games => (
    is      => 'ro',
    isa     => 'HashRef[Bot::Games::Game]',
    lazy    => 1,
    default => sub { {} },
);

has done_init => (
    is      => 'ro',
    isa     => 'HashRef[Bool]',
    lazy    => 1,
    default => sub { {} },
);

has alias => (
    is      => 'ro',
    isa     => 'HashRef[Str]',
    lazy    => 1,
    default => sub { {
        sg => 'superghost',
        xg => 'xghost',
    } },
);

my $say;
my $say_args;

sub BUILD {
    my $self = shift;
    $say = sub {
        shift;
        return $self->say(%$say_args, body => $self->_format(@_)) if @_ == 1;
        my %overrides = @_;
        $overrides{body} = $self->_format($overrides{body})
            if exists $overrides{body};
        return $self->say(%$say_args, %overrides);
    };
    require Bot::Games::Game;
    Bot::Games::Game->meta->add_method(say => $say);
    Bot::Games::Game->meta->make_immutable;
}

sub said {
    my $self = shift;
    my ($args) = @_;
    my $prefix = $self->prefix;
    $say_args = $args;

    return if $args->{channel} eq 'msg';
    return unless $args->{body} =~ /^$prefix(\w+)(?:\s+(.*))?/;
    my ($game_name, $action) = (lc($1), $2);
    return $self->game_list if $game_name eq 'games';
    if ($game_name eq 'help') {
        $game_name = $action;
        $game_name =~ s/^-//;
        $action = '-help';
    }
    $game_name = $self->find_game($game_name);
    return unless $game_name;

    my $output;
    my $game = $self->active_games->{$game_name};
    if (!defined $game) {
        my $game_package = $self->game_package($game_name);
        eval "require $game_package";
        $game = $game_package->new;
        $self->active_games->{$game_name} = $game;
    }
    if (!$self->done_init->{$game_name}
     && (!defined($action) || $action !~ /^-/)) {
        $self->$say($game->init($args->{who})) if $game->can('init');
        $self->done_init->{$game_name} = 1;
    }

    return unless defined $action;

    if ($action =~ /^-(\w+)\s*(.*)/) {
        my ($action, $arg) = ($1, $2);
        # XXX: maybe the meta stuff should get pushed out into the plugins
        # themselves, and this should become $game->meta->get_command or so?
        if (my $method_meta = _get_command($game, $action)) {
            if ($method_meta->needs_init && !$self->done_init->{$game_name}) {
                $self->$say("Game $game_name hasn't started yet!");
                return;
            }
            $self->$say($method_meta->execute($game, $arg,
                                              {player => $args->{who}}));
        }
        else {
            $self->$say("Unknown command $action for game $game_name");
            return;
        }
    }
    else {
        # XXX: need better handling for "0", but B::BB doesn't currently
        # handle that properly either, so
        # also, this should probably be factored into $say, i think?
        my $turn = $game->turn($args->{who}, $action);
        $self->$say($turn) if $turn;
    }

    if ($game->is_over) {
        delete $self->active_games->{$game_name};
        delete $self->done_init->{$game_name};
    }

    return;
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
    return 'Bot::Games::Game::' . ucfirst($name);
}

sub game_list {
    my $self = shift;
    return join ' ', sort map { s/Bot::Games::Game:://; $self->prefix . lc }
                              $self->games;
}

sub find_game {
    my $self = shift;
    my ($abbrev) = @_;
    return $abbrev if $self->valid_game($abbrev);
    return $self->alias->{$abbrev}
        if exists $self->alias->{$abbrev}
        && $self->valid_game($self->alias->{$abbrev});
    my @possibilities = grep { /^$abbrev/ } $self->game_list;
    return $possibilities[0] if @possibilities == 1;
    return;
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
        $to_print = 'false';
    }
    return $to_print;
}

sub _get_command {
    my ($game, $action) = @_;
    my $method_meta = $game->meta->find_method_by_name($action);
    return $method_meta
        if blessed($method_meta)
        && $method_meta->meta->can('does_role')
        && $method_meta->meta->does_role('Bot::Games::Meta::Role::Command');
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Bot::Games::OO;

1;
