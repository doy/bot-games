package Bot::Games;
use Bot::Games::OO;
use Module::Pluggable
    search_path => 'Bot::Games::Game',
    sub_name    => 'games';
extends 'Bot::BasicBot';

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
        unshift @_, 'body' if @_ % 2 == 1;
        my %overrides = @_;
        my $formatter = delete $overrides{formatter};
        $overrides{body} = $formatter->($overrides{body})
            if $formatter && exists $overrides{body};
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
    return join ' ', map { $self->prefix . $_} $self->game_list
        if $game_name eq 'games';
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
    if (!$self->active_games->{$game_name}->is_active
     && (!defined($action) || $action !~ /^-/)) {
        $self->$say($game->init($args->{who})) if $game->can('init');
        $self->active_games->{$game_name}->is_active(1);
    }

    return unless defined $action;

    if ($action =~ /^-(\w+)\s*(.*)/) {
        my ($action, $arg) = ($1, $2);
        if (my $method_meta = $game->meta->get_command($action)) {
            if ($method_meta->needs_init
             && !$self->active_games->{$game_name}->is_active) {
                $self->$say("Game $game_name hasn't started yet!");
                return;
            }
            my $body = $method_meta->execute($game, $arg,
                                             {player => $args->{who}});
            my @extra_args = $method_meta->meta->does_role('Bot::Games::Trait::Method::Formatted') ? (formatter => $method_meta->formatter) : ();
            $self->$say($body, @extra_args);
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

    if (!$game->is_active) {
        delete $self->active_games->{$game_name};
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
    return sort map { s/Bot::Games::Game:://; lc } $self->games;
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

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Bot::Games::OO;

1;
