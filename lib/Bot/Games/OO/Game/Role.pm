package Bot::Games::OO::Game::Role;
use Bot::Games::OO::Role ();

# XXX: is there a better way to go about this?
*command = \&Bot::Games::OO::Game::command;
Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Bot::Games::OO::Role'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose::Role->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class =>
            $options{for_class},
        attribute_metaclass_roles =>
            ['Bot::Games::Trait::Attribute::Command',
             'Bot::Games::Trait::Attribute::Formatted'],
        metaclass_roles =>
            ['Bot::Games::Trait::Class::Command',
             'Bot::Games::Trait::Class::Formatted'],
    );
    return $options{for_class}->meta;
}

1;
