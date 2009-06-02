package Bot::Games::Trait::Class::Command;
use Bot::Games::OO::Role;

after ((map { "add_${_}_method_modifier" } qw/before after around/) => sub {
    my $self = shift;
    my $name = shift;

    my $method_meta = $self->get_method($name);
    my $orig_method_meta = $method_meta->get_original_method;
    return unless $orig_method_meta->meta->can('does_role')
               && $orig_method_meta->meta->does_role('Bot::Games::Trait::Method::Command');
    my $pass_args = $orig_method_meta->pass_args;
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [blessed $method_meta],
        roles        => ['Bot::Games::Trait::Method::Command'],
        cache        => 1,
    );
    $method_metaclass->rebless_instance($method_meta, pass_args => $pass_args);
});

sub get_command {
    my $self = shift;
    my ($action) = @_;
    my $method_meta = $self->find_method_by_name($action);
    return $method_meta
        if blessed($method_meta)
        && $method_meta->meta->can('does_role')
        && $method_meta->meta->does_role('Bot::Games::Trait::Method::Command');
}

no Bot::Games::OO::Role;

1;
