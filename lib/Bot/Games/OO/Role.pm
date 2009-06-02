package Bot::Games::OO::Role;
use Moose ();
use MooseX::AttributeHelpers;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    also => ['Moose::Role'],
);

1;
