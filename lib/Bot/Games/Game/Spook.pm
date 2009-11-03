package Bot::Games::Game::Spook;
use Bot::Games::OO;
use Games::Word qw/is_subpermutation/;
extends 'Bot::Games::Game::Ghost';

has '+help' => (
    default => "spook help",
);

command valid_move => sub {
    my $self = shift;
    my ($move) = @_;
    return is_subpermutation($self->state, uc($move))
        && length($self->state) + 1 == length($move);
}, formatter => 'Bool';

command valid_word_from_state => sub {
    my $self = shift;
    my ($word) = @_;
    return is_subpermutation($self->state, uc($word));
}, formatter => 'Bool';

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
