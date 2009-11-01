package Bot::Games;
use Moose;
use Config::Any;
use IM::Engine;
with 'MooseX::ConfigFromFile';

has '+configfile' => (
    default => "$ENV{HOME}/.botgamesrc",
);

has protocol => (
    is      => 'ro',
    isa     => 'Str',
    default => 'REPL',
);

has name => (
    is  => 'ro',
    isa => 'Str',
);

has password => (
    is  => 'ro',
    isa => 'Str',
);

has server => (
    is  => 'ro',
    isa => 'Str',
);

has port => (
    is      => 'ro',
    isa     => 'Int',
    default => 6667,
);

has channels => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

has namespace => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Bot::Games::Game',
);

has exclude_commands => (
    is      => 'ro',
    isa     => 'Str|RegexpRef|ArrayRef[Str|RegexpRef]',
    default => sub { qr/^Bot::Games::Game::Role/ },
);

has only_commands => (
    is  => 'ro',
    isa => 'Str|RegexpRef|ArrayRef[Str|RegexpRef]',
);

has prefix => (
    is  => 'ro',
    isa => 'Str',
);

has alias => (
    is  => 'ro',
    isa => 'HashRef[Str]',
);

has _credentials => (
    is       => 'ro',
    isa      => 'Maybe[HashRef]',
    builder  => '_build_credentials',
    lazy     => 1,
    init_arg => undef,
);

has _plugin_config => (
    is       => 'ro',
    isa      => 'HashRef',
    builder  => '_build_plugin_config',
    lazy     => 1,
    init_arg => undef,
);

has _ime => (
    is       => 'ro',
    isa      => 'IM::Engine',
    builder  => '_build_ime',
    lazy     => 1,
    init_arg => undef,
    handles  => ['run'],
);

sub BUILD {
    my $self = shift;
    $self->_ime;
}

sub _build_credentials {
    my $self = shift;
    my $protocol = $self->protocol;
    if ($protocol eq 'AIM') {
        $self->_check_required(qw(name password));
        return {
            screenname => $self->name,
            password   => $self->password
        };
    }
    elsif ($protocol eq 'Jabber') {
        $self->_check_required(qw(name password));
        return {
            jid      => $self->name,
            password => $self->password,
        };
    }
    elsif ($protocol eq 'IRC') {
        $self->_check_required(qw(server port channels name));
        return {
            server   => $self->server,
            port     => $self->port,
            channels => $self->channels,
            nick     => $self->name,
        };
    }
    return;
}

sub _build_plugin_config {
    my $self = shift;
    my %config;
    $config{namespace} = $self->namespace
        if defined $self->namespace;
    $config{exclude_commands} = $self->exclude_commands
        if defined $self->exclude_commands;
    $config{only_commands} = $self->only_commands
        if defined $self->only_commands;
    $config{prefix} = $self->prefix
        if defined $self->prefix;
    $config{alias} = $self->alias
        if defined $self->alias;
    return \%config;
}

sub _build_ime {
    my $self = shift;
    my $credentials = $self->_credentials;
    my $plugin_config = $self->_plugin_config;
    IM::Engine->new(
        interface => {
            protocol => $self->protocol,
            $credentials ? (credentials => $credentials) : (),
        },
        plugins => [
            Commands => $plugin_config,
        ],
    );
}

# XXX: cargo-culted from mx-simpleconfig, so i can disable use_ext
sub get_config_from_file {
    my ($class, $file) = @_;

    my $raw_cfany = Config::Any->load_files({
        files   => [ $file ],
        use_ext => 0,
    });

    die q{Specified configfile '} . $file
      . q{' does not exist, is empty, or is not readable}
        unless $raw_cfany->[0]
            && exists $raw_cfany->[0]->{$file};

    my $raw_config = $raw_cfany->[0]->{$file};

    die "configfile must represent a hash structure"
        unless $raw_config && ref $raw_config && ref $raw_config eq 'HASH';

    $raw_config;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
