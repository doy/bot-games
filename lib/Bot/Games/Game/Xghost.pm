package Bot::Games::Game::Xghost;
use Bot::Games::OO::Game;
use Games::Word qw/is_substring/;
extends 'Bot::Games::Game::Ghost';

has '+help' => (
    default => "xghost help",
);

command valid_move => sub {
    my $self = shift;
    my ($move) = @_;
    return is_substring($self->state, uc($move))
        && length($self->state) + 1 == length($move);
}, formatter => 'Bool';

command valid_word_from_state => sub {
    my $self = shift;
    my ($word) = @_;
    return is_substring($self->state, uc($move));
}, formatter => 'Bool';

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO::Game;

1;
