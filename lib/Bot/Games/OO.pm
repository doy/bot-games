#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;

use Bot::Games::Meta::Class;

sub command {
    my $class = shift;
    my ($name, $code) = @_;
    my $method_meta = Moose::Meta::Method->wrap(
        $code,
        package_name => $class,
        name         => $name,
    );
    Moose::Util::apply_all_roles($method_meta->meta, 'Bot::Games::Meta::Role::Command');
    $class->meta->add_method($name, $method_meta);
}

Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Moose'],
);

sub init_meta {
    shift;
    return Moose->init_meta(@_, metaclass => 'Bot::Games::Meta::Class');
}

1;
