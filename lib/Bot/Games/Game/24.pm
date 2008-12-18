#!/usr/bin/perl
package Bot::Games::Game::24;
use Moose;
extends 'Bot::Games::Game';

has '+help' => (
    default => '24 help',
);

has state => (
    is      => 'rw',
    isa     => 'Str',
);

has _solution => (
    is      => 'rw',
    isa     => 'Str',
);

sub _init {
    my $self = shift;
    return $self->_generate_24;
}

sub turn {
    my $self = shift;
    my ($player, $expr) = @_;
    my $eval = $self->_evaluate($expr);
    if ($eval == 24) {
        $self->is_over("$player wins!");
        return;
    }
    else {
        return $eval;
    }
}

sub give_up {
    my $self = shift;
    $self->is_over($self->_solution);
    return;
}

my @ops = ('+', '-', '*', '/');

sub _generate_24 {
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
    $self->_solution(join '', @nums);
    $self->state(join ' ', (grep { /\d/ } @nums));
    return $self->state;
}

sub _evaluate {
    my $self = shift;
    my ($expr) = @_;
    return 0 unless $expr =~ /^[-\d\+\*\/\(\)]+$/;
    return eval $expr;
}

1;
