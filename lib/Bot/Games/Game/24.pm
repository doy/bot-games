#!/usr/bin/perl
package Bot::Games::Game::24;
use Bot::Games::OO;
extends 'Bot::Games::Game';

has '+help' => (
    default => '24 help',
);

has state => (
    is      => 'rw',
    isa     => 'Str',
    command => 1,
);

has solution => (
    is      => 'rw',
    isa     => 'Str',
);

sub init {
    my $self = shift;
    return $self->generate_24;
}

augment turn => sub {
    my $self = shift;
    my ($player, $expr) = @_;

    my $numbers = join ',', sort split(/[-\+\*\/\(\)]+/, $expr);
    my $solution = join ',', sort split(' ', $self->state);
    return "invalid numbers" unless $numbers eq $solution;

    my $eval = $self->evaluate($expr);
    if ($eval == 24) {
        $self->is_over("$player wins!");
        return;
    }
    else {
        return $eval;
    }
};

command give_up => sub {
    my $self = shift;
    $self->is_over($self->solution);
    return;
};

my @ops = ('+', '-', '*', '/');

sub generate_24 {
    my $self = shift;
    my @nums = (24);
    for (1..3) {
        my $index = int rand @nums;
        my $val = $nums[$index];
        redo unless $val =~ /\d/;
        redo if $val < 4;
        my $op = @ops[int rand @ops];
        my $n1 = 2 + int rand($val - 3);
        my $n2;
        if ($op eq '+') {
            $n2 = $val - $n1;
        }
        elsif ($op eq '-') {
            $n1 += $val;
            $n2 = $n1 - $val;
        }
        elsif ($op eq '*') {
            $n2 = $val / $n1;
            while ($n2 != int($n2)) {
                $n1 = 2 + int rand($val - 3);
                $n2 = $val / $n1;
            }
        }
        elsif ($op eq '/') {
            $n1 *= $val;
            $n2 = $n1 / $val;
        }
        splice @nums, $index, 1, ('(', $n1, $op, $n2, ')');
    }
    pop @nums;
    shift @nums;
    $self->solution(join '', @nums);
    $self->state(join ' ', (grep { /\d/ } @nums));
    return $self->state;
}

sub evaluate {
    my $self = shift;
    my ($expr) = @_;
    return 0 unless $expr =~ /^[-\d\+\*\/\(\)]+$/;
    return eval $expr;
}

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
