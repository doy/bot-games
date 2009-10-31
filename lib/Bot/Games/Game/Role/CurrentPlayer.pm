package Bot::Games::Game::Role::CurrentPlayer;
use Bot::Games::OO::Role;

requires 'players', 'num_players', 'add_player';

has current_player => (
    is         => 'rw',
    isa        => 'Str',
    predicate  => 'has_current_player',
    command    => 1,
);

command previous_player => sub {
    my $self = shift;
    return unless $self->has_current_player;
    return $self->players->[$self->current_player_index - 1];
};

command next_player => sub {
    my $self = shift;
    return unless $self->has_current_player;
    return $self->players->[($self->current_player_index + 1) % $self->num_players];
};

sub current_player_index {
    my $self = shift;
    for (0..($self->num_players - 1)) {
        return $_ if $self->current_player eq $self->players->[$_];
    }
    return 0;
}

sub maybe_add_player {
    my $self = shift;
    my ($player) = @_;
    if (!grep { $player eq $_ } $self->players) {
        if ($self->add_player($player)) {
            $self->current_player($player);
        }
    }
}

no Bot::Games::OO::Role;

1;
