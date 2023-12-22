# -*- mode: perl; -*-

# Test
# - Math::BigInt -> bbrsft() with and without upgrading to Math::BigFloat
# - Math::BigFloat -> bbrsft() with and without downgrading to Math::BigInt

use strict;
use warnings;

use Test::More;

use Math::BigInt;
use Math::BigFloat;

$| = 1;

my @cases =
  (

   [  0,   -1,     0 ],
   [  0,   -1.5,   0 ],
   [  0,   -1,     0 ],

   [  7,   -1,    14 ],
   [  7,   -1,    14 ],
   [  7.5, -1,    14 ],
   [  7,   -1.5,  14 ],
   [  7.5, -1.5,  14 ],

   [ -7,   -1,   -14 ],
   [ -7.5, -1,   -14 ],
   [ -7,   -1.5, -14 ],
   [ -7.5, -1.5, -14 ],

   [  7,    1,     3 ],
   [  7.5,  1,     3 ],
   [  7,    1.5,   3 ],
   [  7.5,  1.5,   3 ],

   [ -7,    1,    -4 ],
   [ -7.5,  1,    -4 ],
   [ -7,    1.5,  -4 ],
   [ -7.5,  1.5,  -4 ],

   # NaN

   [ "NaN",   0,    "NaN" ],
   [ "NaN",  -1,    "NaN" ],
   [ "NaN",  -1.5,  "NaN" ],
   [ "NaN", "-inf", "NaN" ],
   [ "NaN",   1,    "NaN" ],
   [ "NaN",   1.5,  "NaN" ],
   [ "NaN",  "inf", "NaN" ],
   [ "NaN",  "NaN", "NaN" ],

   [  0,     "NaN", "NaN" ],
   [  1,     "NaN", "NaN" ],
   [  1.5,   "NaN", "NaN" ],
   [  "inf", "NaN", "NaN" ],
   [ -1,     "NaN", "NaN" ],
   [ -1.5,   "NaN", "NaN" ],
   [ "-inf", "NaN", "NaN" ],
   [ "NaN",  "NaN", "NaN" ],

   # inf

   [ "inf",   0,    "inf" ],
   [ "inf",  -1,    "inf" ],
   [ "inf",  -1.5,  "inf" ],
   [ "inf", "-inf", "inf" ],
   [ "inf",   1,    "inf" ],
   [ "inf",   1.5,  "inf" ],
   [ "inf",  "inf", "NaN" ],

   [  0,   "-inf",  "NaN" ],
   [  1,   "-inf",  "inf" ],
   [  1.5, "-inf",  "inf" ],
   [ -1,   "-inf", "-inf" ],
   [ -1.5, "-inf", "-inf" ],

   # -inf (note that floored division is used here)

   [ "-inf",   0,    "-inf" ],  # -inf / 2**(0) = -inf
   [ "-inf",  -1,    "-inf" ],  # -inf / 2**(-1) = -inf
   [ "-inf",  -1.5,  "-inf" ],  # -inf / 2**(-1.5) = -inf
   [ "-inf", "-inf", "-inf" ],  # -inf / 2**(-inf) = -inf * 2**(inf) = -inf
   [ "-inf",   1,    "-inf" ],  # -inf / 2**(1) = -inf / 2 = -inf
   [ "-inf",   1.5,  "-inf" ],  # -inf / 2**(1.5) = -inf / 2**(1.5) = -inf
   [ "-inf",  "inf",  "NaN" ],  # -inf / 2**(inf) = -inf / 2**(inf) = NaN

   [  0,    "inf",  0 ],        # 0 / 2**(inf) = 0 / inf = 0
   [  1,    "inf",  0 ],        # 1 / 2**(inf) = 1 / inf = 0
   [  1.5,  "inf",  0 ],        # 1.5 / 2**(inf) = 0
   [ -1,    "inf", -1 ],        # -1 / 2**(inf) = -1
   [ -1.5,  "inf", -1 ],        # -1.5 / 2**(inf) = -1

  );

# Add more test cases.

if (1) {
    my @x = ("-inf", "inf", "NaN", map { $_ / 4} -25 .. 25);
    my @y = ("-inf", "inf", "NaN", map { $_ / 4} -25 .. 25);
    for my $x (@x) {
        for my $y (@y) {
            my $xint = Math::BigFloat -> new($x) -> as_int();
            my $yint = Math::BigFloat -> new($y) -> as_int();
            my $z = $yint < 0 ? $xint -> bmul(Math::BigInt -> new(2) -> bpow(-$yint))
                              : $xint -> bdiv(Math::BigInt -> new(2) -> bpow($yint));
            $z = $z -> bint();
            $z = $z -> is_nan()    ?  "NaN"
               : $z -> is_inf("+") ?  "inf"
               : $z -> is_inf("-") ? "-inf"
               : $z -> numify();
            push @cases, [ $x, $y, $z ];
        }
    }
}

# If called as an instance method.

for my $upg (undef, "Math::BigFloat") {
    for my $dng (undef, "Math::BigInt") {

        Math::BigInt -> upgrade($upg);
        Math::BigFloat -> downgrade($dng);

        for my $case (@cases) {
            my ($xscl, $yscl, $zscl) = @$case;

            my @xref = ('Math::BigFloat');
            my @yref = ('Math::BigFloat', '');

            unshift @xref, 'Math::BigInt' unless $xscl =~ /\./;
            unshift @yref, 'Math::BigInt' unless $yscl =~ /\./;

            for my $xref (@xref) {
                for my $yref (@yref) {

                    # The output class is identical to the class of the
                    # invocand, except if we are downgrading.

                    my $zref = $dng ? "Math::BigInt" : $xref;

                    # test "$x -> bbrsft($y)", which modifies $x

                    note "\n";
                    note "Math::BigInt -> upgrade(", defined($upg) ? "\"$upg\"" : "undef", ");",
                      " Math::BigFloat -> downgrade(", defined($dng) ? "\"$dng\"" : "undef", ");",
                      $xref ? " \$x = $xref -> new(\"$xscl\");" : " \$x = $xscl;",
                      $yref ? " \$y = $yref -> new(\"$yscl\");" : " \$y = $yscl;",
                      " \$z = \$x -> bbrsft(\$y);",
                      " print \$z\n";
                    note "\n";

                    {
                        my $x = $xref ? $xref -> new($xscl) : $xscl;
                        my $y = $yref ? $yref -> new($yscl) : $yscl;

                        my $z = eval { $x -> bbrsft($y) };
                        is($@, '', "eval succeeded");

                        is(ref($z), $zref, "output class is $zref");
                        is($z, $zscl, "output value is $zscl");
                        is($x, $z, "invocand value $z is the output");
                    }

                    # test "$x >>= $y", which modifies $x

                    note "\n";
                    note "Math::BigInt -> upgrade(", defined($upg) ? "\"$upg\"" : "undef", ");",
                      " Math::BigFloat -> downgrade(", defined($dng) ? "\"$dng\"" : "undef", ");",
                      $xref ? " \$x = $xref -> new(\"$xscl\");" : " \$x = $xscl;",
                      $yref ? " \$y = $yref -> new(\"$yscl\");" : " \$y = $yscl;",
                      " \$z = \$x >>= \$y;",
                      " print \$z\n";
                    note "\n";

                    {
                        my $x = $xref ? $xref -> new($xscl) : $xscl;
                        my $y = $yref ? $yref -> new($yscl) : $yscl;

                        my $z = eval { $x >>= $y };
                        is($@, '', "eval succeeded");

                        is(ref($z), $zref, "output class is $zref");
                        is($z, $zscl, "output value is $zscl");
                        is($x, $z, "invocand value $z is the output");
                    }

                    # test "$x >> $y", which does not modify $x

                    note "\n";
                    note "Math::BigInt -> upgrade(", defined($upg) ? "\"$upg\"" : "undef", ");",
                      " Math::BigFloat -> downgrade(", defined($dng) ? "\"$dng\"" : "undef", ");",
                      $xref ? " \$x = $xref -> new(\"$xscl\");" : " \$x = $xscl;",
                      $yref ? " \$y = $yref -> new(\"$yscl\");" : " \$y = $yscl;",
                      " \$z = \$x >> \$y;",
                      " print \$z\n";
                    note "\n";

                    {
                        my $x = $xref ? $xref -> new($xscl) : $xscl;
                        my $y = $yref ? $yref -> new($yscl) : $yscl;

                        my $z = eval { $x >> $y };
                        is($@, '', "eval succeeded");

                        is(ref($z), $zref, "output class is $zref");
                        is($z, $zscl, "output value is $zscl");
                        is($x, $xscl, "invocand value $xscl is unmodified");
                    }
                }
            }
        }
    }
}

# If called as a class method.

for my $upg (undef, "Math::BigFloat") {
    for my $dng (undef, "Math::BigInt") {

        Math::BigInt -> upgrade($upg);
        Math::BigFloat -> downgrade($dng);

        for my $ref ("Math::BigInt", "Math::BigFloat") {

            for my $case (@cases) {
                my ($xscl, $yscl, $zscl) = @$case;

                my @xref = ('Math::BigFloat', '');
                my @yref = ('Math::BigFloat', '');

                unshift @xref, 'Math::BigInt' unless $xscl =~ /\./;
                unshift @yref, 'Math::BigInt' unless $yscl =~ /\./;

                for my $xref (@xref) {
                    for my $yref (@yref) {

                        # The output class is identical to the calling class,
                        # except if we are downgrading.

                        my $zref = $dng ? "Math::BigInt" : $ref;

                        my $x = $xref ? $xref -> new($xscl) : $xscl;
                        my $y = $yref ? $yref -> new($yscl) : $yscl;

                        note "\n";
                        note "Math::BigInt -> upgrade(", defined($upg) ? "\"$upg\"" : "undef", ");",
                          " Math::BigFloat -> downgrade(", defined($dng) ? "\"$dng\"" : "undef", ");",
                          $xref ? " \$x = $xref -> new(\"$xscl\");" : " \$x = \"$xscl\";",
                          $yref ? " \$y = $yref -> new(\"$yscl\");" : " \$y = \"$yscl\";",
                          " \$z = $ref -> bbrsft(\$x, \$y);",
                          " print \$z\n";
                        note "\n";

                        my $z = eval { $ref -> bbrsft($x, $y) };
                        is($@, '', "eval succeeded");

                        is(ref($z), $zref, "output class is $zref");
                        is($z, $zscl, "output value is $zscl");

                        # What happens when we are upgrading and/or downgrading
                        # is more complicated, so ignore these cases for now.

                        if ($ref eq "Math::BigInt" && $xref eq "Math::BigInt"
                              ||
                            $ref eq "Math::BigFloat" && $xref eq "Math::BigFloat" && !$dng)
                        {
                            is($x, $z, "invocand is the output (value is $zscl)");
                        }
                    }
                }
            }
        }
    }
}

done_testing();
