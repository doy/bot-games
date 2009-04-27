package Bot::Games::Trait::Method::Formatted;
use Moose::Role;

has formatter => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub { sub {
        warn "no formatter specified!";
        return @_;
    } },
);

no Moose::Role;

1;
