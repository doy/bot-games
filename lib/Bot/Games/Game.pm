package Bot::Games::Game;
use Bot::Games::OO;
use DateTime;

has help => (
    is         => 'ro',
    isa        => 'Str',
    default    => 'This game doesn\'t have any help text!',
    command    => 1,
    needs_init => 0,
);

# XXX: traits has to be specified manually here because the metaclass option
# overrides anything set up by MetaRole - once MXAH can use traits, we should
# just use that instead.
has players => (
    metaclass  => 'Collection::Array',
    traits     => [qw/Bot::Games::Meta::Role::Attribute/],
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push  => 'add_player',
        count => 'num_players',
    },
    command    => 1,
);
command 'num_players';

has _start_time => (
    is         => 'ro',
    isa        => 'DateTime',
    default    => sub { DateTime->now },
);

has _last_turn_time => (
    is         => 'rw',
    isa        => 'DateTime',
);

has is_over => (
    is         => 'rw',
    isa        => 'Bool',
    command    => 1,
);

sub turn {
    my $turn = inner();
    return $turn if defined($turn);
    return "Games must provide a turn method";
}
after turn => sub { shift->_last_turn_time(DateTime->now) };

sub allow_new_player { 1 }
around add_player => sub {
    my $orig = shift;
    my $self = shift;
    if ($self->allow_new_player) {
        $self->$orig(@_);
        return 1;
    }
    return;
};

command cmdlist => sub {
    my $self = shift;
    my @commands;
    for my $method ($self->meta->get_all_methods) {
        push @commands, $method->name
            if $method->meta->can('does_role')
            && $method->meta->does_role('Bot::Games::Meta::Role::Command');
    }
    return join ' ', sort map { '-' . $_ } @commands;
}, needs_init => 0;

command start_time => sub {
    my $self = shift;
    return $self->diff_from_now($self->_start_time);
};

command last_turn_time => sub {
    my $self = shift;
    return $self->diff_from_now($self->_last_turn_time);
};

# XXX: this would be much nicer as an external module, but the only one that
# really does what i want (DateTime::Format::Human::Duration) has only had one
# release, which doesn't pass tests. bleh.
sub diff_from_now {
    my $self = shift;
    my ($dt) = @_;
    my $dur = DateTime->now - $dt;
    my @units = qw/weeks days hours minutes seconds/;
    $dur->in_units(@units);
    my @dur_values = map { $dur->$_ . " $_" } grep { $dur->$_ } @units;
    return join(', ', @dur_values) . " ago";
}

# this happens in Bot::Games, since we want to add the say method from there
#__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
