package Bot::Games::Game::Chess;
use Bot::Games::OO::Game;
extends 'Bot::Games::Game';

use MooseX::AttributeHelpers;
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
    traits   => ['Counter'],
    is       => 'ro',
    isa      => 'Int',
    default  => 1,
    provides => {
        inc => 'inc_turn',
    }
);

augment turn => sub {
    my $self = shift;
    my ($player, $move) = @_;
    $self->add_player($player) unless $self->has_player($player);
    return unless $self->has_player($player);

    my $status = eval { $self->game->go_move($move) };
    return $@ if $@;
    my $desc = $self->format_turn($status);
    $self->game->inc_counter if $self->game->to_move;
    $self->is_active(0) if $self->game->status->{mate}
                        || $self->game->status->{stalemate};

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

sub format_turn {
    my $self = shift;
    my ($turn) = @_;
    my $ret = $self->turn_count . ". ";
    if ($self->game->to_move) {
        $ret .= "... ";
    }
    $ret .= $turn->{san};
}

1;
