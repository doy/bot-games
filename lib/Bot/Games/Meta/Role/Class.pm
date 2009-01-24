#!/usr/bin/perl
package Bot::Games::Meta::Role::Class;
use Moose::Role;

after ((map { "add_${_}_method_modifier" } qw/before after around/) => sub {
    my $self = shift;
    my $name = shift;

    my $method_meta = $self->get_method($name);
    my $orig_method_meta = $method_meta->get_original_method;
    return unless $orig_method_meta->meta->can('does_role')
               && $orig_method_meta->meta->does_role('Bot::Games::Meta::Role::Command');
    my $pass_args = $orig_method_meta->pass_args;
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [blessed $method_meta],
        roles        => ['Bot::Games::Meta::Role::Command'],
        cache        => 1,
    );
    $method_metaclass->rebless_instance($method_meta, pass_args => $pass_args);
});

no Moose::Role;

1;
