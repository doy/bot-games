package Bot::Games::OO;
use IM::Engine::Plugin::Commands::OO ();
use MooseX::AttributeHelpers;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    also => ['IM::Engine::Plugin::Commands::OO'],
);

1;
