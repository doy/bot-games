#!/usr/bin/perl
package Bot::Games::Meta::Role::Attribute;
use Moose::Role;

has command => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has needs_init => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around accessor_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    my $metaclass = $self->$orig(@_);
    return $metaclass unless $self->command;
    return Moose::Meta::Class->create_anon_class(
        superclasses => [$metaclass],
        roles        => ['Bot::Games::Meta::Role::Command'],
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
