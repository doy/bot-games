#!/usr/bin/perl
package Bot::Games::OO;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

sub command {
    my $class = shift;
    my ($name, $code, %args) = @_;
    my $method_meta = $class->meta->get_method($name);
    my $superclass = Moose::blessed($method_meta) || 'Moose::Meta::Method';
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [$superclass],
        roles        => ['Bot::Games::Meta::Role::Command'],
        cache        => 1,
    );
    if ($method_meta) {
        $method_metaclass->rebless_instance($method_meta);
    }
    else {
        $method_meta = $method_metaclass->name->wrap(
            $code,
            package_name => $class,
            name         => $name,
        );
        $class->meta->add_method($name, $method_meta);
    }
    for my $attr (Bot::Games::Meta::Role::Command->meta->get_attribute_list) {
        $method_meta->$attr($args{$attr}) if exists $args{$attr};
    }
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
        metaclass_roles           => ['Bot::Games::Meta::Role::Class',
                                      'MooseX::NonMoose::Meta::Role::Class'],
        constructor_metaclass_roles =>
            ['MooseX::NonMoose::Meta::Role::Constructor'],
    );
    return $options{for_class}->meta;
}

1;
