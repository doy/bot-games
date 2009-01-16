#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Bot::Games::Meta::Class;

sub command {
    my $class = shift;
    my ($name, $code) = @_;
    my $method_meta = Moose::Meta::Method->wrap(
        $code,
        package_name => $class,
        name         => $name,
    );
    $method_meta->command(1);
    $class->meta->add_method($name, $method_meta);
}

Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Moose'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options, metaclass => 'Bot::Games::Meta::Class');
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class => $options{for_class},
        method_metaclass_roles => ['Bot::Games::Meta::Role::Command'],
    );
    return $options{for_class}->meta;
}

1;
