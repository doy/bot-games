#!/usr/bin/perl
package Bot::Games::Meta::Attribute;
use Moose;
extends 'Moose::Meta::Attribute';

has command => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has commands => (
    is      => 'rw'
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    default => sub { [] },
);

after install_accessors => sub {
    my $self = shift;
    my $accessor_meta = $self->get_read_method_ref;
    if ($self->command) {
        Moose::Util::apply_all_roles($accessor_meta, 'Bot::Games::Meta::Role::Command');
        # don't let plugins pass arguments to reader methods
        $accessor_meta->pass_args(0);
    }
    for my $method (@{ $self->commands }) {
        my $method_meta = $self->find_method_by_name($method);
        Moose::Util::apply_all_roles($method_meta, 'Bot::Games::Meta::Role::Command');
        # don't let plugins pass arguments to generated methods (?)
        $accessor_meta->pass_args(0);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
