package Bot::Games::OO::Game;
use Bot::Games::OO ();

sub command {
    my $class = shift;
    my ($name, $code, %args) = @_;
    my $method_meta = $class->meta->get_method($name);
    my $superclass = Moose::blessed($method_meta) || 'Moose::Meta::Method';
    my @method_metaclass_roles = ('Bot::Games::Trait::Method::Command');
    push @method_metaclass_roles, 'Bot::Games::Trait::Method::Formatted'
        if $args{formatter};
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [$superclass],
        roles        => [@method_metaclass_roles],
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
    for my $attr (map { $_->meta->get_attribute_list } @method_metaclass_roles) {
        $method_meta->$attr($args{$attr}) if exists $args{$attr};
    }
}

Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Bot::Games::OO'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class =>
            $options{for_class},
        attribute_metaclass_roles =>
            ['Bot::Games::Trait::Attribute::Command',
             'Bot::Games::Trait::Attribute::Formatted'],
        metaclass_roles =>
            ['Bot::Games::Trait::Class::Command'],
    );
    return $options{for_class}->meta;
}

1;
