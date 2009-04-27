package Bot::Games::Trait::Attribute::Formatted;
use Moose::Role;

# when the attribute is being constructed, the accessor methods haven't been
# generated yet, so we need to store the formatter here, and then apply it
# after the accessor methods exist
has formatter => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'has_formatter',
);

after install_accessors => sub {
    my $self = shift;
    if ($self->has_formatter) {
        my $formatter = $self->formatter;
        my $method_meta = $self->get_read_method_ref;
        $method_meta->formatter($formatter)
            if $method_meta->can('formatter');
    }
};

no Moose::Role;

1;
