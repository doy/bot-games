#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

sub command {
    my $class = shift;
    my ($name, $code) = @_;
    my $superclass = 'Moose::Meta::Method';
    if (!$code) {
        my $method_meta = $class->meta->remove_method($name);
        die "Can't set $name as a command, it doesn't exist"
            unless blessed $method_meta;
        $superclass = blessed $method_meta;
        $code = $method_meta->body;
    }
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [$superclass],
        roles        => ['Bot::Games::Meta::Role::Command'],
        cache        => 1,
    )->name;
    my $method_meta = $method_metaclass->wrap(
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
        metaclass_roles           => ['Bot::Games::Meta::Role::Class'],
    );
    return $options{for_class}->meta;
}

1;
