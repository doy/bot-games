#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Bot::Games::Meta::Method::Command;

sub command {
    my $class = shift;
    my ($name, $code) = @_;
    return unless $code; # XXX: fix this later
    my $method_meta = Bot::Games::Meta::Method::Command->wrap(
        $code,
        package_name => $class,
        name         => $name,
    );
    $class->meta->add_method($name, $method_meta);
}

Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Moose'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class                 => $options{for_class},
        attribute_metaclass_roles => ['Bot::Games::Meta::Role::Attribute'],
    );
    return $options{for_class}->meta;
}

1;
