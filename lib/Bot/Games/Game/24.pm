package Bot::Games::Game::24;
use Bot::Games::OO;

use List::Util qw/shuffle/;
use Math::Expression::Evaluator;
use Time::Duration;
use Try::Tiny;

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
    my ($player) = @_;
    $self->add_player($player) unless $self->has_player($player);
    return $self->generate_24;
}

sub turn {
    my $self = shift;
    my ($player, $expr) = @_;
    $self->add_player($player) unless $self->has_player($player);

    $expr =~ s/\s//g;
    my $numbers = join ',', sort grep { $_ } split(/[-\+\*\/\(\)]+/, $expr);
    my $solution = join ',', sort split(' ', $self->state);
    return "invalid numbers" unless $numbers eq $solution;

    my $eval = $self->evaluate($expr);
    if (defined($eval) && $eval == 24) {
        $self->is_active(0);
        return "$player wins! ("
             . concise(duration_exact(time - $self->start_time->epoch))
             . ")";
    }
    else {
        return "$expr = " . (defined($eval) ? $eval : 'undef');
    }
};

command give_up => sub {
    my $self = shift;
    $self->is_active(0);
    return $self->solution;
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
            redo if ($n2 != int($n2));
        }
        elsif ($op eq '/') {
            $n1 *= $val;
            $n2 = $n1 / $val;
        }
        redo if $n1 >= 1000 || $n2 >= 1000;
        splice @nums, $index, 1, ('(', $n1, $op, $n2, ')');
    }
    pop @nums;
    shift @nums;
    $self->solution(join '', @nums);
    $self->state(join ' ', shuffle(grep { /\d/ } @nums));
    return $self->state;
}

sub evaluate {
    my $self = shift;
    my ($expr) = @_;
    return unless $expr =~ /^[-\d\+\*\/\(\)]+$/;
    return try { Math::Expression::Evaluator->new->parse($expr)->val };
}

__PACKAGE__->meta->make_immutable;
no Bot::Games::OO;

1;
