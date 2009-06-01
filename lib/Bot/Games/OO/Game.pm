package Bot::Games::OO::Game;
use Bot::Games::OO ();

sub command {
    my $class = shift;
    my $name = shift;
    my $code;
    $code = shift if ref($_[0]) eq 'CODE';
    my %args = @_;

    my $method_meta = $class->meta->get_method($name);
    my $superclass = Moose::blessed($method_meta) || 'Moose::Meta::Method';
    my @method_metaclass_roles = ('Bot::Games::Trait::Method::Command');
    push @method_metaclass_roles, 'Bot::Games::Trait::Method::Formatted'
        if $args{formatter};
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [$superclass],
        roles        => \@method_metaclass_roles,
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
        next unless exists $args{$attr};
        my $value = $args{$attr};
        my $munge_method = "_munge_$attr";
        $value = $method_meta->$munge_method($value)
            if $method_meta->can($munge_method);
        $method_meta->$attr($value);
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
            ['Bot::Games::Trait::Class::Command',
             'Bot::Games::Trait::Class::Formatted'],
    );
    return $options{for_class}->meta;
}

1;
