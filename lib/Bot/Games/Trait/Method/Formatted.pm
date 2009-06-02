package Bot::Games::Trait::Method::Formatted;
use Bot::Games::OO::Role;

has formatter => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub { sub {
        warn "no formatter specified!";
        return @_;
    } },
);

sub _munge_formatter {
    my $self = shift;
    my ($format) = @_;
    return $format if ref($format) eq 'CODE';
    return $self->associated_metaclass->formatter_for($format);
}

no Bot::Games::OO::Role;

1;
