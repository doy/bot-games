#!/usr/bin/perl
package Bot::Games::Meta::Role::Class;
use Moose::Role;

after ((map { "add_${_}_method_modifier" } qw/before after around/) => sub {
    my $self = shift;
    my $name = shift;

    my $method_meta = $self->remove_method($name);
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [blessed $method_meta],
        roles        => ['Bot::Games::Meta::Role::Command'],
        cache        => 1,
    )->name;
    $method_meta = $method_metaclass->wrap($method_meta);
    $self->add_method($name, $method_meta);
});

no Moose::Role;

1;
