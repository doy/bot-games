#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;

use Bot::Games::Meta::Class;
use Bot::Games::Meta::Method::Command;

sub command($&) {
    my $class = shift;
    my ($name, $code) = @_;
    # XXX: is $class->meta what i want? should i be calling some form of
    # ->initialize? should i be calling ->get_metaclass_by_name? who knows!
    $class->meta->add_method($name, Bot::Games::Meta::Method::Command->wrap(
        $code,
        package_name => $class,
        name         => $name,
    ));
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
