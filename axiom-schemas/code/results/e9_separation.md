# E9 (v2): refutation separation between targets

Command: `python3 experiments/e9_separation.py`.

Min is the alignment-complete Min^al. "pairs" = one datum per target (the case to which (S) reduces for an ideal refuter); "sets" = |A|,|B| in {1,2} (v1 protocol). Data that are instances of both targets of the pair are excluded. Refuter: budget 80 per template (v2 search order).

## PA-mix targets

Targets: Q1 = `Ax.~Sx=0`, Q2 = `Ax.Ay.Sx=Sy -> x=y`, Q3 = `Ax.~x=0 -> (Ey.x=Sy)`, Q4 = `Ax.x+0=x`, Q5 = `Ax.Ay.x+Sy=S(x+y)`, Q6 = `Ax.x*0=0`, Q7 = `Ax.Ay.x*Sy=x*y+x`, Ind = `(?P(0) & (Ax.?P(x) -> ?P(Sx))) -> (Ax.?P(x))`, U_add0 = `?t+0=?t`, U_mul0 = `?t*0=0`, U_0add = `0+?t=?t`

Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:

| template | count | refuted | pass | refuting instance |
|---|---|---|---|---|
| `?P0` | 1240 | True | top/bot | `1=0` |
| `Ax.?P0(x)` | 720 | True | top/bot | `Ax.1=0` |
| `Ax.Ay.?P0(y,x)` | 120 | True | top/bot | `Ax.Ay.1=0` |
| `?f0=?f1` | 68 | True | one-hot | `1=0` |
| `?f0+?f1=?f2` | 18 | True | one-hot | `1+0=0` |
| `?f0=0` | 12 | True | one-hot | `1=0` |
| `?f0+?f1=S?f2` | 8 | True | top/bot | `0+0=1` |
| `?f0+?f1=SS?f2` | 4 | True | top/bot | `0+0=2` |

| protocol | merges tested | refuted | rate | distinct minimal templates | distinct unrefuted | refutations by pass (distinct templates) | oracle calls |
|---|---|---|---|---|---|---|---|
| pairs | 2200 | 2200 | 100.0% | 15 | 0 | one-hot 4, top/bot 11 | 19 |
| sets | 2200 | 2200 | 100.0% | 13 | 0 | one-hot 3, top/bot 10 | 16 |

## ZF-mix targets

Targets: Ext = `Ax.Ay.(Az.z in x <-> z in y) -> x=y`, Pair = `Ax.Ay.Ez.Au.u in z <-> (u=x | u=y)`, Union = `Ax.Ey.Az.z in y <-> (Eu.u in x & z in u)`, Power = `Ax.Ey.Az.z in y <-> (Au.u in z -> u in x)`, Inf = `Ex.(Ey.y in x & (Az.~z in y)) & (Ay.y in x -> (Ez.z in x & (Au.u in z <-> (u in y | u=y))))`, Found = `Ax.(Ey.y in x) -> (Ey.y in x & (Az.z in y -> ~z in x))`, Sep = `Ax.Ey.Az.z in y <-> (z in x & ?P(z,x))`, Rep = `Ax.(Ay.y in x -> (Ez.?P(y,z,x) & (Au.?P(y,u,x) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ?P(u,z,x)))`, EInd = `(Ax.(Ay.y in x -> ?P(y)) -> ?P(x)) -> (Ax.?P(x))`

Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:

| template | count | refuted | pass | refuting instance |
|---|---|---|---|---|
| `Ax.?P0(x)` | 240 | True | top/bot | `Ax.~(Ay.y=y)` |
| `?P0` | 225 | True | top/bot | `~(Ax.x=x)` |
| `Ax.Ey.Az.z in y <-> ?P0(z,x)` | 45 | True | top/bot | `Ax.Ey.Az.z in y <-> (Au.u=u)` |
| `Ax.Ay.?P0(y,x)` | 15 | True | top/bot | `Ax.Ay.~(Az.z=z)` |
| `Ax.?P0(x) -> (Ey.?P1(y,x))` | 15 | True | top/bot | `Ax.(Ay.y=y) -> (Ey.~(Az.z=z))` |

| protocol | merges tested | refuted | rate | distinct minimal templates | distinct unrefuted | refutations by pass (distinct templates) | oracle calls |
|---|---|---|---|---|---|---|---|
| pairs | 540 | 540 | 100.0% | 5 | 0 | top/bot 5 | 7 |
| sets | 540 | 540 | 100.0% | 5 | 0 | top/bot 5 | 7 |

## PA near-miss targets

Targets: U_add0 = `?t+0=?t`, U_add1 = `?t+1=S?t`, U_mul1 = `?t*1=?t`, U_0add = `0+?t=?t`, U_add00 = `?t+0+0=?t+0`, Ind = `(?P(0) & (Ax.?P(x) -> ?P(Sx))) -> (Ax.?P(x))`, IndSwap = `((Ax.?P(x) -> ?P(Sx)) & ?P(0)) -> (Ax.?P(x))`, IndCurry = `?P(0) -> ((Ax.?P(x) -> ?P(Sx)) -> (Ax.?P(x)))`

Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:

| template | count | refuted | pass | refuting instance |
|---|---|---|---|---|
| `?P0` | 600 | True | top/bot | `1=0` |
| `?f0+?f1=?f2` | 119 | True | one-hot | `1+0=0` |
| `?f0=?f1` | 85 | True | one-hot | `1=0` |
| `?P0 -> ?P1` | 76 | True | top/bot | `0=0 -> 1=0` |
| `(?P0 & ?P1) -> (Ax.?P2(x))` | 26 | True | top/bot | `(0=0 & 0=0) -> (Ax.1=0)` |
| `?f0=SS?f1` | 19 | True | top/bot | `0=2` |
| `?f0=S?f1` | 19 | True | top/bot | `0=1` |
| `?f0+?f1=S?f2` | 16 | True | top/bot | `0+0=1` |

Target pairs with an unrefuted merge (pairs): U_add0/U_add1 36 of 40 separated; U_0add/U_add00 37 of 40 separated

Examples of unrefuted cross-target merges (pairs; data; surviving minimal templates):

* U_add0 / U_add1: data `SSSSS0+0=SSSSS0 ; SSSSS0+1=SSSSSS0`; surviving `SSSSS0+?f0=SSSSS?f0`
* U_add0 / U_add1: data `2+0=2 ; 2+1=3`; surviving `2+?f0=SS?f0`
* U_add0 / U_add1: data `1+0=1 ; 1+1=2`; surviving `1+?f0=S?f0`
* U_add0 / U_add1: data `SSSSSSS0+0=SSSSSSS0 ; SSSSSSS0+1=SSSSSSSS0`; surviving `SSSSSSS0+?f0=SSSSSSS?f0`
* U_0add / U_add00: data `0+0=0 ; 0*(0*3)+0+0=0*(0*3)+0`; surviving `?f0+0=?f0`

| protocol | merges tested | refuted | rate | distinct minimal templates | distinct unrefuted | refutations by pass (distinct templates) | oracle calls |
|---|---|---|---|---|---|---|---|
| pairs | 1080 | 1073 | 99.4% | 61 | 5 | one-hot 12, top/bot 44 | 113 |
| sets | 1080 | 1080 | 100.0% | 36 | 0 | one-hot 9, top/bot 27 | 63 |

## ZF near-miss targets

Targets: Sep = `Ax.Ey.Az.z in y <-> (z in x & ?P(z,x))`, SepSwap = `Ax.Ey.Az.z in y <-> (?P(z,x) & z in x)`, Rep = `Ax.(Ay.y in x -> (Ez.?P(y,z,x) & (Au.?P(y,u,x) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ?P(u,z,x)))`, EInd = `(Ax.(Ay.y in x -> ?P(y)) -> ?P(x)) -> (Ax.?P(x))`, FoundS = `(Ex.?P(x)) -> (Ex.?P(x) & (Ay.y in x -> ~?P(y)))`, Found = `Ax.(Ey.y in x) -> (Ey.y in x & (Az.z in y -> ~z in x))`

Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:

| template | count | refuted | pass | refuting instance |
|---|---|---|---|---|
| `?P0` | 120 | True | top/bot | `~(Ax.x=x)` |
| `Ax.?P0(x)` | 60 | True | top/bot | `Ax.~(Ay.y=y)` |
| `Ax.Ey.Az.z in y <-> (?P0(z,x) & ?P1(z,x))` | 15 | True | top/bot | `Ax.Ey.Az.z in y <-> ((Au.u=u) & (Au.u=u))` |
| `Ax.?P0(x) -> (Ey.?P1(y,x))` | 15 | True | top/bot | `Ax.(Ay.y=y) -> (Ey.~(Az.z=z))` |
| `?P0 -> ?P1` | 15 | True | top/bot | `(Ax.x=x) -> ~(Ax.x=x)` |

| protocol | merges tested | refuted | rate | distinct minimal templates | distinct unrefuted | refutations by pass (distinct templates) | oracle calls |
|---|---|---|---|---|---|---|---|
| pairs | 225 | 225 | 100.0% | 5 | 0 | top/bot 5 | 10 |
| sets | 225 | 225 | 100.0% | 5 | 0 | top/bot 5 | 10 |

## ZF hard targets (v2)

Targets: Sep = `Ax.Ey.Az.z in y <-> (z in x & ?P(z,x))`, SepU = `Ax.Ey.Az.z in y <-> ((Eu.u in x & z in u) & ?P(z,x))`, Rep = `Ax.(Ay.y in x -> (Ez.?P(y,z,x) & (Au.?P(y,u,x) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ?P(u,z,x)))`, Coll = `Ax.(Ay.y in x -> (Ez.?P(y,z,x))) -> (Ey.Az.z in x -> (Eu.u in y & ?P(z,u,x)))`, EInd = `(Ax.(Ay.y in x -> ?P(y)) -> ?P(x)) -> (Ax.?P(x))`, EInd2 = `(Ax.(Ay.y in x -> (Az.z in y -> ?P(z))) -> ?P(x)) -> (Ax.?P(x))`, FoundS = `(Ex.?P(x)) -> (Ex.?P(x) & (Ay.y in x -> ~?P(y)))`, UnionW = `Ax.Ey.Az.(Eu.u in x & z in u) -> z in y`, PowerW = `Ax.Ey.Az.(Au.u in z -> u in x) -> z in y`

Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:

| template | count | refuted | pass | refuting instance |
|---|---|---|---|---|
| `?P0` | 216 | True | top/bot | `~(Ax.x=x)` |
| `Ax.?P0(x)` | 96 | True | top/bot | `Ax.~(Ay.y=y)` |
| `Ax.Ey.Az.?P0(z,y,x)` | 48 | True | top/bot | `Ax.Ey.Az.~(Au.u=u)` |
| `?P0 -> ?P1` | 24 | True | top/bot | `(Ax.x=x) -> ~(Ax.x=x)` |
| `Ax.Ey.Az.?P0(z,x) -> z in y` | 12 | True | top/bot | `Ax.Ey.Az.(Au.u=u) -> z in y` |
| `Ax.Ey.Az.z in y <-> (?P0(z,x) & ?P1(z,x))` | 11 | True | top/bot | `Ax.Ey.Az.z in y <-> ((Au.u=u) & (Au.u=u))` |
| `(Ax.(Ay.y in x -> ?P0(y)) -> ?P1(x)) -> (Ax.?P1(x))` | 9 | True | one-hot | `(Ax.(Ay.y in x -> ~(Az.z=z)) -> (Ay.~y in x)) -> (Ax.Ay.~y in x)` |
| `Ax.(Ay.y in x -> (Ez.?P0(z,y,x))) -> (Ey.Az.?P1(z,y,x))` | 7 | True | top/bot | `Ax.(Ay.y in x -> (Ez.~(Au.u=u))) -> (Ey.Az.~(Au.u=u))` |

Target pairs with an unrefuted merge (pairs): EInd/EInd2 11 of 12 separated

Examples of unrefuted cross-target merges (pairs; data; surviving minimal templates):

* EInd / EInd2: data `(Ax.(Ay.y in x -> (Az.z in y -> (Eu.z in y))) -> (Ay.y in x -> (Ez.y in x))) -> (Ax.Ay.y in x -> (Ez.y in x)) ; (Ax.(Ay.y in x -> (Az.z in y -> z in z)) -> x in x) -> (Ax.x in x)`; surviving `(Ax.(Ay.y in x -> (Az.z in y -> ?P0(z,y))) -> ?P1(x)) -> (Ax.?P1(x))`

Target pairs with an unrefuted merge (sets): EInd/EInd2 10 of 12 separated

Examples of unrefuted cross-target merges (sets; data; surviving minimal templates):

* EInd / EInd2: data `(Ax.(Ay.y in x -> (Az.z in y -> z=z)) -> (Ay.y in x -> y=y)) -> (Ax.Ay.y in x -> y=y) ; (Ax.(Ay.y in x -> (Az.z in y -> (Au.u in z -> u in z))) -> (Ay.y in x -> y in x)) -> (Ax.Ay.y in x -> y in x) ; (Ax.(Ay.y in x -> (Az.z in y -> (Eu.u in z & (Av.v in u -> z in z)))) -> (Ey.y in x & (Az.z in y -> x in x))) -> (Ax.Ey.y in x & (Az.z in y -> x in x))`; surviving `(Ax.(Ay.y in x -> (Az.z in y -> ?P0(z))) -> ?P1(x)) -> (Ax.?P1(x))`
* EInd / EInd2: data `(Ax.(Ay.y in x -> (Az.z in y -> (Au.Av.v in y -> v in v))) -> (Ay.y in x -> (Az.Au.u in x -> u in u))) -> (Ax.Ay.y in x -> (Az.Au.u in x -> u in u)) ; (Ax.(Ay.y in x -> (Az.z in y -> (z=z -> z in z))) -> (x=x -> x in x)) -> (Ax.x=x -> x in x)`; surviving `(Ax.(Ay.y in x -> (Az.z in y -> ?P0(z,y))) -> ?P1(x)) -> (Ax.?P1(x))`

| protocol | merges tested | refuted | rate | distinct minimal templates | distinct unrefuted | refutations by pass (distinct templates) | oracle calls |
|---|---|---|---|---|---|---|---|
| pairs | 432 | 431 | 99.8% | 14 | 1 | one-hot 3, top/bot 10 | 108 |
| sets | 432 | 430 | 99.5% | 15 | 2 | one-hot 3, top/bot 10 | 167 |

Wall time: 2.4s
