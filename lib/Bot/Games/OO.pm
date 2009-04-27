package Bot::Games::OO;
use Moose ();
use MooseX::AttributeHelpers;
use Moose::Exporter;
use Moose::Util::MetaRole;

Moose::Exporter->setup_import_methods(
    also => ['Moose'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class                   => $options{for_class},
        metaclass_roles             => ['MooseX::NonMoose::Meta::Role::Class'],
        constructor_metaclass_roles =>
            ['MooseX::NonMoose::Meta::Role::Constructor'],
    );
    return $options{for_class}->meta;
}

1;
