#!/usr/bin/perl
package Bot::Games::Meta::Attribute;
use Moose;
extends 'Moose::Meta::Attribute';

has public => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

before _process_options => sub {
    my $self = shift;
    my %args = @_;
    die "Public accessors must be read-only"
        if $args{is} eq 'rw' && $args{public};
};

around accessor_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    $self->public ? 'Bot::Games::Meta::Method::Command' : $self->$orig(@_);
};

no Moose;

1;
