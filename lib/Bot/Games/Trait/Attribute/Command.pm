package Bot::Games::Trait::Attribute::Command;
use Moose::Role;

has command => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has needs_init => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

before _process_options => sub {
    my $self = shift;
    my ($name, $options) = @_;
    warn "needs_init is useless for attributes without command"
        if exists($options->{needs_init}) && !$options->{command};
};

around accessor_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    my $metaclass = $self->$orig(@_);
    return $metaclass unless $self->command;
    return Moose::Meta::Class->create_anon_class(
        superclasses => [$metaclass],
        roles        => ['Bot::Games::Trait::Method::Command'],
        cache        => 1,
    )->name;
};

after install_accessors => sub {
    my $self = shift;
    return unless $self->command;
    my $method_meta = $self->get_read_method_ref;
    $method_meta->pass_args(0);
    $method_meta->needs_init($self->needs_init);
};

no Moose::Role;

1;
