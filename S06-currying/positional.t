use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Assuming;

plan 232;

is-primed-sig(sub () { }, :(), );
is-primed-sig(sub ($a) { }, :(), 1);
is-primed-sig(sub ($a, $b) { }, :($b), 1);
is-primed-sig(sub ($a?) { }, :(), 1);
is-primed-sig(sub ($a, $b?) { }, :($b?), 1);
is-primed-sig(sub ($a?, $b?) { }, :($b?), 1);
is-primed-sig(sub ($a = 2) { }, :(), 1);
is-primed-sig(sub ($a = 4, $b = 2) { }, :($b?), 1);
is-primed-sig(sub ($a where { True }, $b where { True }) { }, :($b), 1);
is-primed-sig(sub ($a where { True } = 4, $b where { True } = 2) { }, :($b?), 1);
is-primed-sig(sub ($a is raw) { }, :(), 1);
is-primed-sig(sub ($a is raw = 4, $b is raw = 4) { }, :($b? is raw), 1);
is-primed-sig(sub ($a is raw where { True }, $b is raw where { True }) { }, :($b is raw), 1);
is-primed-sig(sub ($a is raw where { True } = 4, $b is raw where { True } = 2) { }, :($b? is raw), 1);
is-primed-sig(sub ($a is copy) { }, :(), 1);
is-primed-sig(sub ($a is copy = 4, $b is copy = 4) { }, :($b? is copy), 1);
is-primed-sig(sub ($a is copy where { True }, $b is copy where { True }) { }, :($b is copy), 1);
is-primed-sig(sub ($a is copy where { True } = 4, $b is copy where { True } = 2) { }, :($b? is copy), 1);
is-primed-sig(sub ($a is rw) { }, :(), 1);
is-primed-sig(sub ($a is rw where { True }, $b is rw where { True }) { }, :($b is rw), 1);
is-primed-sig(sub ($a, $b) { }, :($b), Nil);
is-primed-sig(sub ($a, $b) { }, :($a), *, 2);
is-primed-sig(sub ($a, $b, $c) { }, :($b), 1, *, 3);
is-primed-sig(sub ($a) { }, :($a), *);
is-primed-sig(sub ($) { }, :(), 1);
is-primed-sig(sub ($, $b) { }, :($b), 1);
is-primed-sig(sub ($?) { }, :(), 1);
is-primed-sig(sub ($, $b?) { }, :($b?), 1);
is-primed-sig(sub ($?, $b?) { }, :($b?), 1);
is-primed-sig(sub ($ = 2) { }, :(), 1);
is-primed-sig(sub ($ = 4, $b = 2) { }, :($b?), 1);
is-primed-sig(sub ($ where { True }, $ where { True }) { }, :($), 1);
is-primed-sig(sub ($ where { True } = 4, $ where { True } = 2) { }, :($?), 1);
is-primed-sig(sub ($ is raw) { }, :(), 1);
is-primed-sig(sub ($ is raw = 4, $ is raw = 4) { }, :($? is raw), 1);
is-primed-sig(sub ($ is raw where { True }, $ is raw where { True }) { }, :($ is raw), 1);
is-primed-sig(sub ($ is raw where { True } = 4, $ is raw where { True } = 2) { }, :($? is raw), 1);
is-primed-sig(sub ($ is copy) { }, :(), 1);
is-primed-sig(sub ($ is copy = 4, $ is copy = 4) { }, :($? is copy), 1);
is-primed-sig(sub ($ is copy where { True }, $ is copy where { True }) { }, :($ is copy), 1);
is-primed-sig(sub ($ is copy where { True } = 4, $ is copy where { True } = 2) { }, :($? is copy), 1);
is-primed-sig(sub ($ is rw) { }, :(), 1);
is-primed-sig(sub ($ is rw where { True }, $ is rw where { True }) { }, :($ is rw), 1);
is-primed-sig(sub ($, $b) { }, :($b), Nil);
is-primed-sig(sub ($, $b) { }, :($), *, 2);
is-primed-sig(sub ($, $b, $c) { }, :($b), 1, *, 3);
is-primed-sig(sub ($) { }, :($), *);
is-primed-sig(sub ($, $) { }, :($), 1);
is-primed-sig(sub ($, $?) { }, :($?), 1);
is-primed-sig(sub ($?, $?) { }, :($?), 1);
is-primed-sig(sub ($ = 2) { }, :(), 1);
is-primed-sig(sub ($ = 4, $ = 2) { }, :($?), 1);
is-primed-sig(sub ($, $) { }, :($), Nil);
is-primed-sig(sub ($, $) { }, :($), *, 2);
is-primed-sig(sub ($, $b, $) { }, :($b), 1, *, 3);
is-primed-sig(sub ($, $, $) { }, :($), 1, *, 3);
is-primed-sig(sub ($, 2) { }, :(Int $), 1);
is-primed-sig(sub (Int $a, Int $b) { }, :(Int $b), 1);
is-primed-sig(sub (Int $, Int $b) { }, :(Int $b), 1);
is-primed-sig(sub (Int $, Int $) { }, :(Int $), 1);
is-primed-sig(sub (Int $a, Int $) { }, :(Int $), 1);
is-primed-sig(sub (Int $a, Str $b) { }, :(Str $b), 1);
is-primed-sig(sub (Int $, Str $b) { }, :(Str $b), 1);
is-primed-sig(sub (Int $, Str $) { }, :(Str $), 1);
is-primed-sig(sub (Int $a, Str $) { }, :(Str $), 1);
is-primed-sig(sub (Int $a, Int $) { }, :(Int $), Nil);
is-primed-sig(sub (Int $a, Str $b) { }, :(Int $a), *, "a");
is-primed-sig(sub (Int $, Str $b) { }, :(Int $), *, "a");
is-primed-sig(sub (Int $, Str $) { }, :(Int $), *, "a");
is-primed-sig(sub (Int $a, Str $) { }, :(Int $a), *, "a");
is-primed-sig(sub (Int $a, Str $) { }, :(), 1, Nil);
is-primed-sig(sub (Str(Int) $a, Str(Int) $b) { }, :(Str(Int) $b), 1);
is-primed-sig(sub (Str(Int) $, Str(Int) $b) { }, :(Str(Int) $b), 1);
is-primed-sig(sub (Str(Int) $, Str(Int) $) { }, :(Str(Int) $), 1);
is-primed-sig(sub (Str(Int) $a, Str(Int) $) { }, :(Str(Int) $), 1);
is-primed-sig(sub (int8 $a, int8 $b) { }, :(int8 $b), 1);
is-primed-sig(sub (int8 $, int8 $b) { }, :(int8 $b), 1);
is-primed-sig(sub (int8 $, int8 $) { }, :(int8 $), 1);
is-primed-sig(sub (int8 $a, int8 $) { }, :(int8 $), 1);
my $XAH = X::AdHoc.new(:payload<foo>);
is-primed-sig(sub (X::AdHoc $a, X::AdHoc $b) { }, :(X::AdHoc $b), $XAH);
is-primed-sig(sub (X::AdHoc $, X::AdHoc $b) { }, :(X::AdHoc $b), $XAH);
is-primed-sig(sub (X::AdHoc $, X::AdHoc $) { }, :(X::AdHoc $), $XAH);
is-primed-sig(sub (X::AdHoc $a, X::AdHoc $) { }, :(X::AdHoc $), $XAH);
my Int @AoI = 1,2;
my Str @AoS = <a b>;
my int8 @aoi8 = 1,2;
my X::AdHoc @AoXAH = $XAH,$XAH;
my Array[Int] @AoAoI = $@AoI,$@AoI;
my Array[X::AdHoc] @AoAoXAH = $@AoXAH,$@AoXAH;
is-primed-sig(sub (Array[Str] $a, Array[Int] $b) { }, :(Array[Int] $b), $@AoS);
is-primed-sig(sub (Array[Str] $, Array[Int] $b) { }, :(Array[Int] $b), $@AoS);
is-primed-sig(sub (Array[Str] $, Array[Int] $) { }, :(Array[Int] $), $@AoS);
is-primed-sig(sub (Array[Str] $a, Array[Int] $) { }, :(Array[Int] $), $@AoS);
is-primed-sig(sub (Array[Str] $a, Array[Int] $b) { }, :(Array[Str] $a), *, $@AoI);
is-primed-sig(sub (Array[Str] $, Array[Int] $b) { }, :(Array[Str] $), *, $@AoI);
is-primed-sig(sub (Array[Str] $, Array[Int] $) { }, :(Array[Str] $), *, $@AoI);
is-primed-sig(sub (Array[Str] $a, Array[Int] $) { }, :(Array[Str] $a), *, $@AoI);
is-primed-sig(sub (Array[X::AdHoc] $a, Array[X::AdHoc] $b) { }, :(Array[X::AdHoc] $b), $@AoXAH);
is-primed-sig(sub (Array[X::AdHoc] $, Array[X::AdHoc] $b) { }, :(Array[X::AdHoc] $b), $@AoXAH);
is-primed-sig(sub (Array[X::AdHoc] $, Array[X::AdHoc] $) { }, :(Array[X::AdHoc] $), $@AoXAH);
is-primed-sig(sub (Array[X::AdHoc] $a, Array[X::AdHoc] $) { }, :(Array[X::AdHoc] $), $@AoXAH);
is-primed-sig(sub (Array[Array[Int]] $a, Array[Array[Int]] $b) { }, :(Array[Array[Int]] $b), $@AoAoI);
is-primed-sig(sub (Array[Array[Int]] $, Array[Array[Int]] $b) { }, :(Array[Array[Int]] $b), $@AoAoI);
is-primed-sig(sub (Array[Array[Int]] $, Array[Array[Int]] $) { }, :(Array[Array[Int]] $), $@AoAoI);
is-primed-sig(sub (Array[Array[Int]] $a, Array[Array[Int]] $) { }, :(Array[Array[Int]] $), $@AoAoI);
is-primed-sig(sub (Array[Array[X::AdHoc]] $a, Array[Array[X::AdHoc]] $b) { }, :(Array[Array[X::AdHoc]] $b), $@AoAoXAH);
is-primed-sig(sub (Array[Array[X::AdHoc]] $, Array[Array[X::AdHoc]] $b) { }, :(Array[Array[X::AdHoc]] $b), $@AoAoXAH);
is-primed-sig(sub (Array[Array[X::AdHoc]] $, Array[Array[X::AdHoc]] $) { }, :(Array[Array[X::AdHoc]] $), $@AoAoXAH);
is-primed-sig(sub (Array[Array[X::AdHoc]] $a, Array[Array[X::AdHoc]] $) { }, :(Array[Array[X::AdHoc]] $), $@AoAoXAH);
is-primed-sig(sub (@a) { }, :(), $[1]);
is-primed-sig(sub (@a, @b) { }, :(@b), $[1]);
is-primed-sig(sub (@a?) { }, :(), $[1]);
is-primed-sig(sub (@a, @b?) { }, :(@b?), $[1]);
is-primed-sig(sub (@a?, @b?) { }, :(@b?), $[1]);
is-primed-sig(sub (@a = 2) { }, :(), $[1]);
is-primed-sig(sub (@a = 4, @b = 2) { }, :(@b?), $[1]);
is-primed-sig(sub (@a, @b) { }, :(@b), Nil);
is-primed-sig(sub (@a, @b) { }, :(@a), *, $[2]);
is-primed-sig(sub (@a, @b, $c) { }, :(@b), $[1], *, $[3]);
is-primed-sig(sub (@a) { }, :(@a), *);
is-primed-sig(sub (@) { }, :(), $[1]);
is-primed-sig(sub (@, @b) { }, :(@b), $[1]);
is-primed-sig(sub (@?) { }, :(), $[1]);
is-primed-sig(sub (@, @b?) { }, :(@b?), $[1]);
is-primed-sig(sub (@?, @b?) { }, :(@b?), $[1]);
is-primed-sig(sub (@ = 2) { }, :(), $[1]);
is-primed-sig(sub (@ = 4, @b = 2) { }, :(@b?), $[1]);
is-primed-sig(sub (@, @b) { }, :(@b), Nil);
is-primed-sig(sub (@, @b) { }, :(@), *, $[2]);
is-primed-sig(sub (@, @b, @c) { }, :(@b), $[1], *, $[3]);
is-primed-sig(sub (@) { }, :(@), *);
is-primed-sig(sub (@, @) { }, :(@), $[1]);
is-primed-sig(sub (@, @?) { }, :(@?), $[1]);
is-primed-sig(sub (@?, @?) { }, :(@?), $[1]);
is-primed-sig(sub (@ = 2) { }, :(), $[1]);
is-primed-sig(sub (@ = 4, @ = 2) { }, :(@?), $[1]);
is-primed-sig(sub (@, @) { }, :(@), Nil);
is-primed-sig(sub (@, @) { }, :(@), *, $[2]);
is-primed-sig(sub (@, @b, @) { }, :(@b), $[1], *, $[3]);
is-primed-sig(sub (@, @, @) { }, :(@), $[1], *, $[3]);
is-primed-sig(sub (@, [2]) { }, :(@), $[1]);
is-primed-sig(sub (Int @a, Int @b) { }, :(Int @b), $@AoI);
is-primed-sig(sub (Int @, Int @b) { }, :(Int @b), $@AoI);
is-primed-sig(sub (Int @, Int @) { }, :(Int @), $@AoI);
is-primed-sig(sub (Int @a, Int @) { }, :(Int @), $@AoI);
is-primed-sig(sub (Int @a, Str @b) { }, :(Str @b), $@AoI);
is-primed-sig(sub (Int @, Str @b) { }, :(Str @b), $@AoI);
is-primed-sig(sub (Int @, Str @) { }, :(Str @), $@AoI);
is-primed-sig(sub (Int @a, Str @) { }, :(Str @), $@AoI);
is-primed-sig(sub (Int @a, Str @b) { }, :(Int @a), *, $@AoS);
is-primed-sig(sub (Int @, Str @b) { }, :(Int @), *, $@AoS);
is-primed-sig(sub (Int @, Str @) { }, :(Int @), *, $@AoS);
is-primed-sig(sub (Int @a, Str @) { }, :(Int @a), *, $@AoS);
is-primed-sig(sub (Str(Int) @a, Str(Int) @b) { }, :(Str(Int) @b), $@AoI);
is-primed-sig(sub (Str(Int) @, Str(Int) @b) { }, :(Str(Int) @b), $@AoI);
is-primed-sig(sub (Str(Int) @, Str(Int) @) { }, :(Str(Int) @), $@AoI);
is-primed-sig(sub (Str(Int) @a, Str(Int) @) { }, :(Str(Int) @), $@AoI);
is-primed-sig(sub (int8 @a, int8 @b) { }, :(int8 @b), $@aoi8);
is-primed-sig(sub (int8 @, int8 @b) { }, :(int8 @b), $@aoi8);
is-primed-sig(sub (int8 @, int8 @) { }, :(int8 @), $@aoi8);
is-primed-sig(sub (int8 @a, int8 @) { }, :(int8 @), $@aoi8);
is-primed-sig(sub (Array[X::AdHoc] @a, Array[X::AdHoc] @b) { }, :(Array[X::AdHoc] @b), $@AoAoXAH);
is-primed-sig(sub (Array[X::AdHoc] @, Array[X::AdHoc] @b) { }, :(Array[X::AdHoc] @b), $@AoAoXAH);
is-primed-sig(sub (Array[X::AdHoc] @, Array[X::AdHoc] @) { }, :(Array[X::AdHoc] @), $@AoAoXAH);
is-primed-sig(sub (Array[X::AdHoc] @a, Array[X::AdHoc] @) { }, :(Array[X::AdHoc] @), $@AoAoXAH);
is-primed-sig(sub (Array[Str] @a, Array[Int] @b) { }, :(Array[Str] @a), *, $@AoAoI);
is-primed-sig(sub (Array[Str] @, Array[Int] @b) { }, :(Array[Str] @), *, $@AoAoI);
is-primed-sig(sub (Array[Str] @, Array[Int] @) { }, :(Array[Str] @), *, $@AoAoI);
is-primed-sig(sub (Array[Str] @a, Array[Int] @) { }, :(Array[Str] @a), *, $@AoAoI);
my X::AdHoc %HoXAH = a => $XAH, b => $XAH;
my Int %HoI = a => 1, b => 2;
my Str %HoS = a => 'A', b => 'B';
my Array[Int] %HoAoI = a => $@AoI, b => $@AoI;
my Hash[X::AdHoc] %HoHoXAH = a => $%HoXAH, b=> $%HoXAH;
is-primed-sig(sub (%a) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (%a, %b) { }, :(%b), {:1a,:2b}.item);
is-primed-sig(sub (%a?) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (%a, %b?) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (%a?, %b?) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (%a = 2) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (%a = 4, %b = 2) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (%a, %b) { }, :(%b), Nil);
is-primed-sig(sub (%a, %b) { }, :(%a), *, {:2b}.item);
is-primed-sig(sub (%a, %b, $c) { }, :(%b), {:1a,:2b}.item, *, {:3c}.item);
is-primed-sig(sub (%a) { }, :(%a), *);
is-primed-sig(sub (%) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (%, %b) { }, :(%b), {:1a,:2b}.item);
is-primed-sig(sub (%?) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (%, %b?) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (%?, %b?) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (% = 2) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (% = 4, %b = 2) { }, :(%b?), {:1a,:2b}.item);
is-primed-sig(sub (%, %b) { }, :(%b), Nil);
is-primed-sig(sub (%, %b) { }, :(%), *, {:2b}.item);
is-primed-sig(sub (%, %b, %c) { }, :(%b), {:1a,:2b}.item, *, {:3c}.item);
is-primed-sig(sub (%) { }, :(%), *);
is-primed-sig(sub (%, %) { }, :(%), {:1a,:2b}.item);
is-primed-sig(sub (%, %?) { }, :(%?), {:1a,:2b}.item);
is-primed-sig(sub (%?, %?) { }, :(%?), {:1a,:2b}.item);
is-primed-sig(sub (% = 2) { }, :(), {:1a,:2b}.item);
is-primed-sig(sub (% = 4, % = 2) { }, :(%?), {:1a,:2b}.item);
is-primed-sig(sub (%, %) { }, :(%), Nil);
is-primed-sig(sub (%, %) { }, :(%), *, {:2b}.item);
is-primed-sig(sub (%, %b, %) { }, :(%b), {:1a,:2b}.item, *, {:3c}.item);
is-primed-sig(sub (%, %, %) { }, :(%), {:1a,:2b}.item, *, {:3c}.item);
is-primed-sig(sub (Int %a, Int %b) { }, :(Int %b), $%HoI);
is-primed-sig(sub (Int %, Int %b) { }, :(Int %b), $%HoI);
is-primed-sig(sub (Int %, Int %) { }, :(Int %), $%HoI);
is-primed-sig(sub (Int %a, Int %) { }, :(Int %), $%HoI);
is-primed-sig(sub (Int %a, Str %b) { }, :(Str %b), $%HoI);
is-primed-sig(sub (Int %, Str %b) { }, :(Str %b), $%HoI);
is-primed-sig(sub (Int %, Str %) { }, :(Str %), $%HoI);
is-primed-sig(sub (Int %a, Str %) { }, :(Str %), $%HoI);
is-primed-sig(sub (Int %a, Str %b) { }, :(Int %a), *, $%HoS);
is-primed-sig(sub (Int %, Str %b) { }, :(Int %), *, $%HoS);
is-primed-sig(sub (Int %, Str %) { }, :(Int %), *, $%HoS);
is-primed-sig(sub (Int %a, Str %) { }, :(Int %a), *, $%HoS);
is-primed-sig(sub (Str(Int) %a, Str(Int) %b) { }, :(Str(Int) %b), $%HoI);
is-primed-sig(sub (Str(Int) %, Str(Int) %b) { }, :(Str(Int) %b), $%HoI);
is-primed-sig(sub (Str(Int) %, Str(Int) %) { }, :(Str(Int) %), $%HoI);
is-primed-sig(sub (Str(Int) %a, Str(Int) %) { }, :(Str(Int) %), $%HoI);
is-primed-sig(sub (Hash[X::AdHoc] %a, Hash[X::AdHoc] %b) { }, :(Hash[X::AdHoc] %b), $%HoHoXAH);
is-primed-sig(sub (Hash[X::AdHoc] %, Hash[X::AdHoc] %b) { }, :(Hash[X::AdHoc] %b), $%HoHoXAH);
is-primed-sig(sub (Hash[X::AdHoc] %, Hash[X::AdHoc] %) { }, :(Hash[X::AdHoc] %), $%HoHoXAH);
is-primed-sig(sub (Hash[X::AdHoc] %a, Hash[X::AdHoc] %) { }, :(Hash[X::AdHoc] %), $%HoHoXAH);
is-primed-sig(sub (Array[Str] %a, Array[Int] %b) { }, :(Array[Str] %a), *, $%HoAoI);
is-primed-sig(sub (Array[Str] %, Array[Int] %b) { }, :(Array[Str] %), *, $%HoAoI);
is-primed-sig(sub (Array[Str] %, Array[Int] %) { }, :(Array[Str] %), *, $%HoAoI);
is-primed-sig(sub (Array[Str] %a, Array[Int] %) { }, :(Array[Str] %a), *, $%HoAoI);

priming-fails-bind-ok(sub (Str $a) { }, '$a', Str, 1);
priming-fails-bind-ok(sub (Int(Str) $a) { }, '$a', Int(Str), 1.1);
priming-fails-bind-ok(sub ($a) { }, "", "Too many positionals", 1, 2);

sub abc123 ($a,$b,$c,$o,$t,$th) { $a,$b,$c,$o,$t,$th; }
proto testsubproto ($x, $y) {*}
multi testsubproto (Str $x, $y) { "Str + $y" }
multi testsubproto (Int $x, $y) { "Int + $y" }

is-primed-call(&abc123, \(1,2,3), ['a','b','c',1,2,3], 'a','b','c');
is-primed-call(-> Str $a { $a.WHAT }, \(), [Str], Nil);
is-primed-call(&testsubproto, \(43), ["Int + 43"], 42);
is-primed-call(&testsubproto, \(44), ["Str + 44"], "a Str");
is-primed-call(&atan2, \(2), [atan2(1,2)],1);
is-primed-call(&atan2, \(1), [atan2(1,2)],*,2);



is-primed-call(&substr, \(0,2), $[substr("hello world", 0, 2)], "hello world");
is-primed-call(sub ( *@x) { @x.raku }, \("c","d","e"), [sub ( *@x) { @x.raku }("a","b","c","d","e")], "a", "b");
is-primed-call(sub (**@x) { @x.raku }, \("c","d","e"), [sub (**@x) { @x.raku }("a","b","c","d","e")], "a", "b");
is-primed-call(sub ( +@x) { @x.raku }, \("c","d","e"), [sub ( +@x) { @x.raku }("a","b","c","d","e")], "a", "b");

# Github Issue #1918
subtest 'Sub with slurpy compiles and yields correct results with .assuming' => {
    plan 3;

    my $c     = \(:!b);
    my &s     = (sub ( *@a, :$b) { @a, $b }).assuming(|$c);
    my &s_lol = (sub (**@a, :$b) { @a, $b }).assuming(|$c);
    my &s_one = (sub ( +@a, :$b) { @a, $b }).assuming(|$c);

    my $a := (1, 2, (3, 4));
    is-deeply &s\   ($a), ([ 1, 2,  3, 4   ], False), 'Slurpy (*@)';
    is-deeply &s_lol($a), ([(1, 2, (3, 4)),], False), 'Slurpy_lol (**@)';
    is-deeply &s_one($a), ([ 1, 2, (3, 4)  ], False), 'Slurpy_onearg (+@)';
}

# vim: expandtab shiftwidth=4
