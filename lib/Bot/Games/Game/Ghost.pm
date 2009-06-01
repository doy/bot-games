package Bot::Games::Game::Ghost;
use Bot::Games::OO::Game;
use Games::Word::Wordlist;
extends 'Bot::Games::Game';

has '+help' => (
    default => "ghost help",
);

has current_player => (
    is         => 'rw',
    isa        => 'Str',
    predicate  => 'has_current_player',
    command    => 1,
);

has state => (
    is         => 'rw',
    isa        => 'Str',
    default    => '',
    command    => 1,
);

has challenger => (
    is         => 'rw',
    isa        => 'Str',
    predicate  => 'has_challenger',
    command    => 1,
);
command 'has_challenger';

has wordlist => (
    is         => 'ro',
    isa        => 'Games::Word::Wordlist',
    default    => sub { Games::Word::Wordlist->new('/usr/share/dict/words') },
    handles    => {
        valid_word => 'is_word',
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

augment turn => sub {
    my $self = shift;
    my ($player, $state) = @_;
    $self->maybe_add_player($player);
    return "It's " . $self->current_player . "'s turn!"
        if $player ne $self->current_player;

    return "You must respond to " . $self->challenger . "'s challenge!"
        if $self->has_challenger;
    return "$state isn't a valid move!"
        unless $state =~ /[a-z]/i && $self->valid_move($state);

    $self->current_player($self->next_player);
    return $self->state($state);
};

sub allow_new_player {
    my $self = shift;

    if ($self->current_player_index != 0 && $self->num_players > 1) {
        $self->say("No more players can join the current game");
        return;
    }
    return 1;
}

command challenge => sub {
    my $self = shift;
    my ($word, $args) = @_;
    my $player = $args->{player};
    $self->maybe_add_player($player);
    return "It's " . $self->current_player . "'s turn!"
        if $player ne $self->current_player;

    if ($word) {
        return "$word is not valid for state " . $self->state . "!"
            unless $self->valid_word_from_state($word);

        $self->is_active(0);
        # if there is a challenger, then this is a response by the current
        # player, so if it's valid, the challenger loses, otherwise the current
        # player loses. if there isn't a challenger, then this is asserting
        # that the word exists, so if the word does exist, then the previous
        # player loses, otherwise the current player loses.
        if ($self->valid_word($word)) {
            return "$word is a word! "
                 . ($self->has_challenger ? $self->challenger
                                          : $self->previous_player)
                 . " loses!";
        }
        else {
            return "$word is not a word! "
                 . $self->current_player
                 . " loses!";
        }
    }
    else {
        my $prev = $self->previous_player;
        $self->challenger($player);
        $self->current_player($prev);
        return "$player is challenging $prev!";
    }
};

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

command valid_move => sub {
    my $self = shift;
    my ($move) = @_;
    return uc(substr($move, 0, -1)) eq $self->state;
};

command valid_word_from_state => sub {
    my $self = shift;
    my ($word) = @_;
    my $word_prefix = substr($word, 0, length($self->state));
    return uc($word_prefix) eq $self->state;
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
    if (!$self->has_challenger && !grep { $player eq $_ } $self->players) {
        if ($self->add_player($player)) {
            $self->current_player($player);
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO::Game;

1;
