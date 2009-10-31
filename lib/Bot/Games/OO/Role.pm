package Bot::Games::OO::Role;
use IM::Engine::Plugin::Commands::OO::Role ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    also => ['IM::Engine::Plugin::Commands::OO::Role'],
);

1;
