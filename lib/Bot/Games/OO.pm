package Bot::Games::OO;
use IM::Engine::Plugin::Commands::OO ();
use Moose::Exporter;

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    install => [qw(import unimport)],
    also    => ['IM::Engine::Plugin::Commands::OO'],
);

sub init_meta {
    my ($package, %options) = @_;
    $options{base_class} = 'Bot::Games::Game'
        if !exists $options{base_class}
        && $options{for_class} ne 'Bot::Games::Game';
    IM::Engine::Plugin::Commands::OO->init_meta(%options);
    goto $init_meta;
}

1;
