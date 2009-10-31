package Bot::Games::OO;
use IM::Engine::Plugin::Commands::OO ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    also => ['IM::Engine::Plugin::Commands::OO'],
);

1;
