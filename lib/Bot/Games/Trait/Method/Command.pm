package Bot::Games::Trait::Method::Command;
use Bot::Games::OO::Role;

has pass_args => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

has needs_init => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

around execute => sub {
    my $orig = shift;
    my $self = shift;
    return $self->pass_args ? $self->$orig(@_) : $self->$orig($_[0]);
};

no Bot::Games::OO::Role;

1;
