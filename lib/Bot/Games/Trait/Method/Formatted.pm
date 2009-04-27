package Bot::Games::Trait::Method::Formatted;
use Moose::Role;

has formatter => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub { sub {
        my $self = shift;
        my ($to_print) = @_;
        if (blessed $to_print) {
            $to_print = "$to_print";
        }
        elsif (ref($to_print) && ref($to_print) eq 'ARRAY') {
            $to_print = join ', ', @$to_print;
        }
        elsif (!$to_print) {
            $to_print = 'false';
        }
        return $to_print;
    } },
);

no Moose::Role;

1;
