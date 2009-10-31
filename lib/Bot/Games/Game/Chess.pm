package Bot::Games::Game::Chess;
use Bot::Games::OO;
extends 'Bot::Games::Game';
with 'Bot::Games::Game::Role::CurrentPlayer';

use Chess::Rep;
use App::Nopaste;

has '+help' => (
    default => 'chess help',
);

has game => (
    is      => 'ro',
    isa     => 'Chess::Rep',
    default => sub { Chess::Rep->new },
);

has turn_count => (
    traits   => [qw(Counter)],
    is       => 'ro',
    isa      => 'Int',
    default  => 1,
    handles  => {
        inc_turn => 'inc',
    }
);

sub turn  {
    my $self = shift;
    my ($player, $move) = @_;
    $self->maybe_add_player($player);

    return "The game has already begun between " . join ' and ', $self->players
        unless $self->has_player($player);
    return "It's not your turn"
        if $player ne $self->current_player;

    my $status = eval { $self->game->go_move($move) };
    return $@ if $@;
    my $desc = $self->format_turn($status);
    $self->inc_turn if $self->game->to_move;
    $self->is_active(0) if $self->game->status->{mate}
                        || $self->game->status->{stalemate};
    $self->current_player($self->next_player);

    return "$desc: " . App::Nopaste::nopaste(text => $self->game->dump_pos,
                                             desc => $desc,
                                             nick => $player);
};

around allow_new_player => sub {
    my $orig = shift;
    my $self = shift;
    return if $self->num_players >= 2;
    return $self->$orig(@_);
};

command resign => sub {
    my $self = shift;
    my ($dummy, $args) = @_;
    $self->is_active(0);
    return "$args->{player} resigns: "
         . App::Nopaste::nopaste(text => $self->game->dump_pos,
                                 nick => $args->{player})
};

command state => sub {
    my $self = shift;
    my ($dummy, $args) = @_;
    my $player;
    if ($self->num_players == 2) {
        $player  = $self->current_player;
        $player .= $self->game->to_move ? ' (white)' : ' (black)';
    }
    else {
        $player = $self->game->to_move ? 'White' : 'Black';
    }
    return "$player to play: "
         . App::Nopaste::nopaste(text => $self->game->dump_pos,
                                 nick => $args->{player});
};

sub format_turn {
    my $self = shift;
    my ($turn) = @_;
    my $ret = $self->turn_count . ". ";
    $ret .= "... " if $self->game->to_move;
    $ret .= $turn->{san};
    return $ret;
}

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
