# -*- mode: perl; -*-

use strict;
use warnings;

use Test::More tests => 259;

use Math::BigFloat;

my $class = "Math::BigFloat";

use Math::Complex ();

my $inf = $Math::Complex::Inf;
my $nan = $inf - $inf;

# The following is used to compute the data at the end of this file.

if (0) {
    my @x = (-$inf, -64, -3, -2.5, -2, -1.5, -1, -0.5, 0,
             0.5, 1, 1.5, 2, 2.5, 3, 64, $inf);
    my @y = (-$inf, -3, -2.5, -2, -1.5, -1, -0.5, 0,
             0.5, 1, 1.5, 2, 2.5, 3, $inf);
    for my $x (@x) {
        for my $y (@y) {

            # The exceptions here are based on Wolfram Alpha,
            # https://www.wolframalpha.com/

            my $z = $x == -$inf && $y == 0     ? $nan
                  : $x ==  $inf && $y == 0     ? $nan
                  : $x == -1    && $y == -$inf ? $nan
                  : $x == -1    && $y ==  $inf ? $nan
                  :                              $x ** $y;

            # Unfortunately, Math::Big* uses "inf", not "Inf" as Perl.

            printf "%s\n", join ":", map {   $_ ==  $inf ?  "inf"
                                           : $_ == -$inf ? "-inf"
                                           : $_                   } $x, $y, $z;
        }
    }

    exit;
}

while (<DATA>) {
    s/#.*$//;                   # remove comments
    s/\s+$//;                   # remove trailing whitespace
    next unless length;         # skip empty lines

    my @args = split /:/;
    my $want = pop @args;

    my ($x, $y, $z);

    my $test = qq|\$x = $class -> new("$args[0]"); |
             . qq|\$y = $class -> new("$args[1]"); |
             . qq|\$z = \$x -> bpow(\$y)|;

    eval "$test";
    die $@ if $@;

    subtest $test => sub {
        plan tests => 5;

        is(ref($x), $class, "\$x is still a $class");

        is(ref($y), $class, "\$y is still a $class");
        is($y, $args[1], "\$y is unmodified");

        is(ref($z), $class, "\$z is a $class");

        # If $want is a finite non-integer and $x is finite, measure the
        # relative difference.

        if ($want * 0 == 0 && $want != int $want && $x -> is_finite()) {
            if (abs(($z -> numify() - $want) / $want) < 1e-8) {
                pass("\$z has the right value");
            } else {
                fail("\$z has the right value");
                diag(<<"EOF");
         got: '$z'
    expected: '$want'
EOF
            }
        } else {
            is($z, $want, "\$z has the right value");
        }
    };
}

# Verify that accuracy and precision is restored (CPAN RT #150523).

{
    $class -> accuracy(10);
    is($class -> accuracy(), 10, "class accuracy is 10 before bpow()");
    my $x = $class -> new(12345);
    $x -> bpow(2);
    is($class -> accuracy(), 10, "class accuracy is 10 after bpow()");
}

{
    $class -> precision(-10);
    is($class -> precision(), -10, "class precision is -10 before bpow()");
    my $x = $class -> new(12345);
    $x -> bpow(2);
    is($class -> precision(), -10, "class precision is -10 after bpow()");
}

__END__
-inf:-inf:0
-inf:-3:0
-inf:-2.5:0
-inf:-2:0
-inf:-1.5:0
-inf:-1:0
-inf:-0.5:0
-inf:0:NaN
-inf:0.5:inf
-inf:1:-inf
-inf:1.5:inf
-inf:2:inf
-inf:2.5:inf
-inf:3:-inf
-inf:inf:inf
-64:-inf:0
-64:-3:-3.814697265625e-06
-64:-2.5:NaN
-64:-2:0.000244140625
-64:-1.5:NaN
-64:-1:-0.015625
-64:-0.5:NaN
-64:0:1
-64:0.5:NaN
-64:1:-64
-64:1.5:NaN
-64:2:4096
-64:2.5:NaN
-64:3:-262144
-64:inf:inf
-3:-inf:0
-3:-3:-0.037037037037037
-3:-2.5:NaN
-3:-2:0.111111111111111
-3:-1.5:NaN
-3:-1:-0.333333333333333
-3:-0.5:NaN
-3:0:1
-3:0.5:NaN
-3:1:-3
-3:1.5:NaN
-3:2:9
-3:2.5:NaN
-3:3:-27
-3:inf:inf
-2.5:-inf:0
-2.5:-3:-0.064
-2.5:-2.5:NaN
-2.5:-2:0.16
-2.5:-1.5:NaN
-2.5:-1:-0.4
-2.5:-0.5:NaN
-2.5:0:1
-2.5:0.5:NaN
-2.5:1:-2.5
-2.5:1.5:NaN
-2.5:2:6.25
-2.5:2.5:NaN
-2.5:3:-15.625
-2.5:inf:inf
-2:-inf:0
-2:-3:-0.125
-2:-2.5:NaN
-2:-2:0.25
-2:-1.5:NaN
-2:-1:-0.5
-2:-0.5:NaN
-2:0:1
-2:0.5:NaN
-2:1:-2
-2:1.5:NaN
-2:2:4
-2:2.5:NaN
-2:3:-8
-2:inf:inf
-1.5:-inf:0
-1.5:-3:-0.296296296296296
-1.5:-2.5:NaN
-1.5:-2:0.444444444444444
-1.5:-1.5:NaN
-1.5:-1:-0.666666666666667
-1.5:-0.5:NaN
-1.5:0:1
-1.5:0.5:NaN
-1.5:1:-1.5
-1.5:1.5:NaN
-1.5:2:2.25
-1.5:2.5:NaN
-1.5:3:-3.375
-1.5:inf:inf
-1:-inf:NaN
-1:-3:-1
-1:-2.5:NaN
-1:-2:1
-1:-1.5:NaN
-1:-1:-1
-1:-0.5:NaN
-1:0:1
-1:0.5:NaN
-1:1:-1
-1:1.5:NaN
-1:2:1
-1:2.5:NaN
-1:3:-1
-1:inf:NaN
-0.5:-inf:inf
-0.5:-3:-8
-0.5:-2.5:NaN
-0.5:-2:4
-0.5:-1.5:NaN
-0.5:-1:-2
-0.5:-0.5:NaN
-0.5:0:1
-0.5:0.5:NaN
-0.5:1:-0.5
-0.5:1.5:NaN
-0.5:2:0.25
-0.5:2.5:NaN
-0.5:3:-0.125
-0.5:inf:0
0:-inf:inf
0:-3:inf
0:-2.5:inf
0:-2:inf
0:-1.5:inf
0:-1:inf
0:-0.5:inf
0:0:1
0:0.5:0
0:1:0
0:1.5:0
0:2:0
0:2.5:0
0:3:0
0:inf:0
0.5:-inf:inf
0.5:-3:8
0.5:-2.5:5.65685424949238
0.5:-2:4
0.5:-1.5:2.82842712474619
0.5:-1:2
0.5:-0.5:1.4142135623731
0.5:0:1
0.5:0.5:0.707106781186548
0.5:1:0.5
0.5:1.5:0.353553390593274
0.5:2:0.25
0.5:2.5:0.176776695296637
0.5:3:0.125
0.5:inf:0
1:-inf:1
1:-3:1
1:-2.5:1
1:-2:1
1:-1.5:1
1:-1:1
1:-0.5:1
1:0:1
1:0.5:1
1:1:1
1:1.5:1
1:2:1
1:2.5:1
1:3:1
1:inf:1
1.5:-inf:0
1.5:-3:0.296296296296296
1.5:-2.5:0.362887369301212
1.5:-2:0.444444444444444
1.5:-1.5:0.544331053951817
1.5:-1:0.666666666666667
1.5:-0.5:0.816496580927726
1.5:0:1
1.5:0.5:1.22474487139159
1.5:1:1.5
1.5:1.5:1.83711730708738
1.5:2:2.25
1.5:2.5:2.75567596063108
1.5:3:3.375
1.5:inf:inf
2:-inf:0
2:-3:0.125
2:-2.5:0.176776695296637
2:-2:0.25
2:-1.5:0.353553390593274
2:-1:0.5
2:-0.5:0.707106781186548
2:0:1
2:0.5:1.4142135623731
2:1:2
2:1.5:2.82842712474619
2:2:4
2:2.5:5.65685424949238
2:3:8
2:inf:inf
2.5:-inf:0
2.5:-3:0.064
2.5:-2.5:0.101192885125388
2.5:-2:0.16
2.5:-1.5:0.25298221281347
2.5:-1:0.4
2.5:-0.5:0.632455532033676
2.5:0:1
2.5:0.5:1.58113883008419
2.5:1:2.5
2.5:1.5:3.95284707521047
2.5:2:6.25
2.5:2.5:9.88211768802619
2.5:3:15.625
2.5:inf:inf
3:-inf:0
3:-3:0.037037037037037
3:-2.5:0.0641500299099584
3:-2:0.111111111111111
3:-1.5:0.192450089729875
3:-1:0.333333333333333
3:-0.5:0.577350269189626
3:0:1
3:0.5:1.73205080756888
3:1:3
3:1.5:5.19615242270663
3:2:9
3:2.5:15.5884572681199
3:3:27
3:inf:inf
64:-inf:0
64:-3:3.814697265625e-06
64:-2.5:3.0517578125e-05
64:-2:0.000244140625
64:-1.5:0.001953125
64:-1:0.015625
64:-0.5:0.125
64:0:1
64:0.5:8
64:1:64
64:1.5:512
64:2:4096
64:2.5:32768
64:3:262144
64:inf:inf
inf:-inf:0
inf:-3:0
inf:-2.5:0
inf:-2:0
inf:-1.5:0
inf:-1:0
inf:-0.5:0
inf:0:NaN
inf:0.5:inf
inf:1:inf
inf:1.5:inf
inf:2:inf
inf:2.5:inf
inf:3:inf
inf:inf:inf
