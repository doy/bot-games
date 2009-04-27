package Bot::Games::Trait::Attribute::Formatted;
use Moose::Role;

my %default_formatters = (
    'ArrayRef' => sub {
        my $arrayref = shift;
        return join ', ', @$arrayref;
    },
    'Bool'     => sub {
        my $bool = shift;
        return $bool ? 'true' : 'false';
    },
    'Object'   => sub {
        my $obj = shift;
        return "$obj";
    },
);

# when the attribute is being constructed, the accessor methods haven't been
# generated yet, so we need to store the formatter here, and then apply it
# after the accessor methods exist
has formatter => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'has_formatter',
);

before _process_options => sub {
    my $self = shift;
    my ($name, $options) = @_;
    warn "only commands will have a formatter applied"
        if exists($options->{formatter}) && !$options->{command};
};

after _process_options => sub {
    my $class = shift;
    my ($name, $options) = @_;
    return if exists $options->{formatter};
    return unless $options->{command};
    if (exists $options->{type_constraint}) {
        my $tc = $options->{type_constraint};
        for my $tc_type (keys %default_formatters) {
            if ($tc->is_a_type_of($tc_type)) {
                $options->{formatter} = $default_formatters{$tc_type};
                return;
            }
        }
    }
};

around accessor_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    my $metaclass = $self->$orig(@_);
    return $metaclass unless $self->has_formatter;
    return Moose::Meta::Class->create_anon_class(
        superclasses => [$metaclass],
        roles        => ['Bot::Games::Trait::Method::Formatted'],
        cache        => 1,
    )->name;
};

after install_accessors => sub {
    my $self = shift;
    if ($self->has_formatter) {
        my $formatter = $self->formatter;
        my $method_meta = $self->get_read_method_ref;
        $method_meta->formatter($formatter);
    }
};

no Moose::Role;

1;
