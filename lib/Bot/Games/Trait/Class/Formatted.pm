package Bot::Games::Trait::Class::Formatted;
use Moose::Role;
use MooseX::AttributeHelpers;

has default_formatters => (
    metaclass => 'Collection::ImmutableHash',
    is        => 'ro',
    isa       => 'HashRef[CodeRef]',
    builder   => '_build_default_formatters',
    provides  => {
        get    => 'formatter_for',
        exists => 'has_formatter',
        keys   => 'formattable_tcs',
    },
);

sub _build_default_formatters {
    {
        'ArrayRef' => sub { join ', ', @{ shift() } },
        'Bool'     => sub { return shift() ? 'true' : 'false' },
        'Object'   => sub { shift() . "" },
    }
}

no Moose::Role;

1;
