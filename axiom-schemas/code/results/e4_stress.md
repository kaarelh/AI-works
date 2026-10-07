# E4 (v2): stress sets

Command: `python3 experiments/e4_stress.py`; seeds [0, 1, 2].

Near-miss PA data use the v1 instance distribution for the ?t-targets (numerals, closed terms, parameter form); mistakes (b) are run on both PA regimes; (c) uses numerals only. "post-hoc refuted: False" is not a certificate of validity; see the notes for hand proofs.

## (a) Near-miss targets

PA targets: U_add0 = `?t+0=?t`, U_add1 = `?t+1=S?t`, U_mul1 = `?t*1=?t`, U_0add = `0+?t=?t`, U_add00 = `?t+0+0=?t+0`, Ind = `(?P(0) & (Ax.?P(x) -> ?P(Sx))) -> (Ax.?P(x))`, IndSwap = `((Ax.?P(x) -> ?P(Sx)) & ?P(0)) -> (Ax.?P(x))`, IndCurry = `?P(0) -> ((Ax.?P(x) -> ?P(Sx)) -> (Ax.?P(x)))`

ZF targets: Sep = `Ax.Ey.Az.z in y <-> (z in x & ?P(z,x))`, SepSwap = `Ax.Ey.Az.z in y <-> (?P(z,x) & z in x)`, Rep = `Ax.(Ay.y in x -> (Ez.?P(y,z,x) & (Au.?P(y,u,x) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ?P(u,z,x)))`, EInd = `(Ax.(Ay.y in x -> ?P(y)) -> ?P(x)) -> (Ax.?P(x))`, FoundS = `(Ex.?P(x)) -> (Ex.?P(x) & (Ay.y in x -> ~?P(y)))`, Found = `Ax.(Ey.y in x) -> (Ey.y in x & (Az.z in y -> ~z in x))`

| lang | seed | ARI | clusters | exact | targets | mixed clusters (label:count) | not exact | probes/non-target/refuted | oracle calls | time |
|---|---|---|---|---|---|---|---|---|---|---|
| PA | 0 | 0.923 | 9 | 7 | 8 | U_add0:5+U_add00:6; U_0add:1+U_add1:6; U_add0:1+U_add1:1; U_add0:1+U_add1:1 | U_add00 | 100/4/0 | 821 | 0.66 |
| PA | 1 | 1.0 | 7 | 7 | 8 | U_add0:8+U_add00:7; U_0add:1+U_add1:8; U_0add:5+U_add0:1 | U_add00 | 95/0/0 | 704 | 0.63 |
| PA | 2 | 1.0 | 7 | 6 | 8 | U_0add:1+U_add0:6+U_add00:7; U_0add:1+U_add1:6 | U_0add, U_add00 | 94/0/0 | 610 | 1.54 |
| ZF | 0 | 1.0 | 6 | 6 | 6 | none | - | 93/0/0 | 816 | 4.31 |
| ZF | 1 | 1.0 | 6 | 6 | 6 | none | - | 89/0/0 | 662 | 3.83 |
| ZF | 2 | 1.0 | 6 | 6 | 6 | none | - | 93/0/0 | 782 | 3.92 |

Mixed clusters (a) and their accepted templates (post-hoc refuter result):

* PA s=0: U_add0:1+U_add1:1; accepted `SSSSS0+?f0=SSSSS?f0` (post-hoc refuted: False)
* PA s=0: U_add0:1+U_add1:1; accepted `SSSS0+?f0=SSSS?f0` (post-hoc refuted: False)
* PA s=0: U_0add:1+U_add1:6; accepted `?f0+1=S?f0` (post-hoc refuted: False)
* PA s=0: U_add0:5+U_add00:6; accepted `?f0+0=?f0` (post-hoc refuted: False)
* PA s=1: U_0add:1+U_add1:8; accepted `?f0+1=S?f0` (post-hoc refuted: False)
* PA s=1: U_add0:8+U_add00:7; accepted `?f0+0=?f0` (post-hoc refuted: False)
* PA s=1: U_0add:5+U_add0:1; accepted `0+?f0=?f0` (post-hoc refuted: False)
* PA s=2: U_0add:1+U_add1:6; accepted `?f0+1=S?f0` (post-hoc refuted: False)
* PA s=2: U_0add:1+U_add0:6+U_add00:7; accepted `?f0+0=?f0` (post-hoc refuted: False)

## (b) Injected mistakes

PA: 8 mistakes (wrong step clause phi(x)->phi(x); wrong base phi(S0); conclusion Ax phi(Sx) (true, non-instance); n+0=0) + 3 true non-target sentences. ZF: 6 mistakes (Separation with b free in phi; Ax(phi->phi)->Ax phi; complement comprehension).

| data | refuter budget | seed | ARI (clean data) | exact targets | held-out accepted | fate of mistakes | probes/non-target/refuted | F1 exhibit accepted | oracle calls | time |
|---|---|---|---|---|---|---|---|---|---|---|
| PA/mixed | 80 | 0 | 1.0 | 11/11 | 107/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 7 | 75/27/0 | YES | 1143 | 1.19 |
| PA/mixed | 80 | 1 | 0.9047 | 11/11 | 107/107 | discarded (refuted): 2; merged into Ind: 1; singleton cluster: 8 | 76/27/0 | no | 828 | 0.68 |
| PA/mixed | 80 | 2 | 0.9474 | 11/11 | 107/107 | discarded (refuted): 3; merged into Ind: 1; singleton cluster: 7 | 75/27/0 | no | 755 | 0.98 |
| PA/mixed | 400 | 0 | 1.0 | 11/11 | 107/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 7 | 75/27/0 | YES | 3757 | 2.84 |
| PA/mixed | 400 | 1 | 0.9047 | 11/11 | 107/107 | discarded (refuted): 2; merged into Ind: 1; singleton cluster: 8 | 76/27/0 | no | 2092 | 0.91 |
| PA/mixed | 400 | 2 | 0.9474 | 11/11 | 107/107 | discarded (refuted): 3; merged into Ind: 1; singleton cluster: 7 | 75/27/0 | no | 1946 | 1.29 |
| PA/mixed | 2000 | 0 | 1.0 | 11/11 | 107/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 2; singleton cluster: 7 | 70/18/0 | no | 6503 | 6.1 |
| PA/mixed | 2000 | 1 | 0.9047 | 11/11 | 107/107 | discarded (refuted): 2; merged into Ind: 1; singleton cluster: 8 | 76/27/0 | no | 4332 | 3.37 |
| PA/mixed | 2000 | 2 | 0.9474 | 11/11 | 107/107 | discarded (refuted): 3; merged into Ind: 1; singleton cluster: 7 | 75/27/0 | no | 4190 | 3.73 |
| PA/numerals | 80 | 0 | 0.8459 | 9/11 | 93/107 | discarded (refuted): 2; merged into Ind: 1; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 6 | 91/44/0 | YES | 1217 | 0.86 |
| PA/numerals | 80 | 1 | 0.7934 | 10/11 | 103/107 | discarded (refuted): 2; merged into Ind: 3; merged into Ind+MISTAKE:ind_wrong_concl: 1; merged into Ind+MISTAKE:ind_wrong_step: 1; singleton cluster: 4 | 129/72/0 | no | 1151 | 0.57 |
| PA/numerals | 80 | 2 | 1.0 | 10/11 | 102/107 | discarded (refuted): 3; merged into MISTAKE:ind_wrong_concl: 2; singleton cluster: 6 | 63/16/0 | no | 714 | 0.86 |
| PA/numerals | 400 | 0 | 1.0 | 9/11 | 93/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 7 | 72/27/0 | YES | 3848 | 3.61 |
| PA/numerals | 400 | 1 | 0.844 | 10/11 | 103/107 | discarded (refuted): 2; merged into Ind: 2; merged into Ind+MISTAKE:ind_wrong_concl: 1; merged into Ind+MISTAKE:ind_wrong_step: 1; singleton cluster: 5 | 109/65/0 | no | 3514 | 1.4 |
| PA/numerals | 400 | 2 | 1.0 | 10/11 | 102/107 | discarded (refuted): 3; merged into MISTAKE:ind_wrong_concl: 2; singleton cluster: 6 | 63/16/0 | no | 1624 | 1.77 |
| PA/numerals | 2000 | 0 | 1.0 | 9/11 | 93/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_base: 1; merged into MISTAKE:ind_wrong_concl: 1; singleton cluster: 7 | 72/27/0 | no | 7801 | 7.18 |
| PA/numerals | 2000 | 1 | 0.844 | 10/11 | 103/107 | discarded (refuted): 2; merged into Ind: 2; merged into Ind+MISTAKE:ind_wrong_concl: 1; merged into Ind+MISTAKE:ind_wrong_step: 1; singleton cluster: 5 | 109/65/0 | no | 10684 | 5.45 |
| PA/numerals | 2000 | 2 | 1.0 | 10/11 | 102/107 | discarded (refuted): 3; merged into MISTAKE:ind_wrong_concl: 2; singleton cluster: 6 | 63/16/0 | no | 3048 | 4.82 |
| ZF | 80 | 0 | 0.9082 | 9/9 | 96/96 | discarded (refuted): 3; merged into Sep: 1; singleton cluster: 1 | 87/6/0 | - | 795 | 5.51 |
| ZF | 80 | 1 | 0.8673 | 9/9 | 96/96 | discarded (refuted): 2; merged into EInd: 1; merged into Sep: 2 | 118/44/0 | - | 874 | 4.98 |
| ZF | 80 | 2 | 0.8994 | 9/9 | 96/96 | discarded (refuted): 3; merged into Sep: 2 | 102/18/0 | - | 861 | 4.9 |
| ZF | 400 | 0 | 1.0 | 9/9 | 96/96 | discarded (refuted): 3; singleton cluster: 2 | 68/2/0 | - | 2004 | 10.83 |
| ZF | 400 | 1 | 0.9594 | 9/9 | 96/96 | discarded (refuted): 2; merged into EInd: 1; singleton cluster: 2 | 78/13/0 | - | 2142 | 11.2 |
| ZF | 400 | 2 | 1.0 | 9/9 | 96/96 | discarded (refuted): 3; singleton cluster: 2 | 66/2/0 | - | 2445 | 13.26 |

Mixed final clusters (b) and their accepted templates; post-hoc refuter (budget PA 4000, ZF 1500) result and witness:

* PA/mixed b=80 s=0: MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.?P0(x,0) & ~?P1(x,0)) & (Ax.(Ey.?P0(y,x) & ~?P1(y,x)) -> (Ey.y<Sx & ~?P1(y,Sx)))) -> (Ax.Ey.y<Sx & ~?P1(y,Sx))` (post-hoc refuted: True, `((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)`)
* PA/mixed b=80 s=1: Ind:2+MISTAKE:ind_wrong_concl:1; accepted `(?f0<0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/mixed b=80 s=2: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/mixed b=400 s=0: MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.?P0(x,0) & ~?P1(x,0)) & (Ax.(Ey.?P0(y,x) & ~?P1(y,x)) -> (Ey.y<Sx & ~?P1(y,Sx)))) -> (Ax.Ey.y<Sx & ~?P1(y,Sx))` (post-hoc refuted: True, `((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)`)
* PA/mixed b=400 s=1: Ind:2+MISTAKE:ind_wrong_concl:1; accepted `(?f0<0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/mixed b=400 s=2: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/mixed b=2000 s=0: MISTAKE:ind_wrong_concl:2; accepted `(?P0(0) & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P0(Sx))` (post-hoc refuted: False)
* PA/mixed b=2000 s=1: Ind:2+MISTAKE:ind_wrong_concl:1; accepted `(?f0<0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/mixed b=2000 s=2: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/numerals b=80 s=0: MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.?P0(x,0) & ~?P1(x,0)) & (Ax.(Ey.?P0(y,x) & ~?P1(y,x)) -> (Ey.y<Sx & ~?P1(y,Sx)))) -> (Ax.Ey.y<Sx & ~?P1(y,Sx))` (post-hoc refuted: True, `((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)`)
* PA/numerals b=80 s=0: Ind:3+MISTAKE:ind_wrong_step:1; accepted `((Ax.?P0(x,0) -> ?P1(x,0)) & (Ax.(Ay.?P0(y,x) -> ?P1(y,x)) -> (Ay.?P0(y,Sx) -> ?P2(y,x)))) -> (Ax.Ay.?P0(y,x) -> ?P1(y,x))` (post-hoc refuted: True, `((Ax.0=0 -> 0=0) & (Ax.(Ay.0=0 -> x=0) -> (Ay.0=0 -> 0=0))) -> (Ax.Ay.0=0 -> x=0)`)
* PA/numerals b=80 s=1: Ind:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0+0 & ?P0(x,0)) & (Ax.(Ey.?P1(y,x) & ?P0(y,x)) -> (Ey.?P2(y,x) & ?P3(y,x)))) -> (Ax.Ey.?P1(y,x) & ?P0(y,x))` (post-hoc refuted: False)
* PA/numerals b=80 s=1: Ind:1+MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0*0 & ?P0(x,0)) & (Ax.(Ey.y<x*x & ?P0(y,x)) -> (Ey.?P1(y,x) & ?P2(y,x)))) -> (Ax.Ey.?P3(y,x) & ?P4(y,x))` (post-hoc refuted: False)
* PA/numerals b=80 s=1: Ind:1+MISTAKE:ind_wrong_base:1; accepted `((Ax.?P0(x,0) -> ?P1(x,1)) & (Ax.(Ay.?P0(y,x) -> ?P1(y,x)) -> (Ay.?P0(y,Sx) -> ?P1(y,Sx)))) -> (Ax.Ay.?P0(y,x) -> ?P1(y,x))` (post-hoc refuted: True, `((Ax.0=0 -> ~1=0) & (Ax.(Ay.0=0 -> ~x=0) -> (Ay.0=0 -> ~Sx=0))) -> (Ax.Ay.0=0 -> ~x=0)`)
* PA/numerals b=80 s=1: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/numerals b=80 s=2: MISTAKE:ind_wrong_concl:2; accepted `(?P0(0) & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P0(Sx))` (post-hoc refuted: False)
* PA/numerals b=80 s=2: U_0add:3+U_add0:1; accepted `0+?f0=?f0` (post-hoc refuted: False)
* PA/numerals b=400 s=0: MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.?P0(x,0) & ~?P1(x,0)) & (Ax.(Ey.?P0(y,x) & ~?P1(y,x)) -> (Ey.y<Sx & ~?P1(y,Sx)))) -> (Ax.Ey.y<Sx & ~?P1(y,Sx))` (post-hoc refuted: True, `((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)`)
* PA/numerals b=400 s=1: Ind:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0+0 & ?P0(x,0)) & (Ax.(Ey.?P1(y,x) & ?P0(y,x)) -> (Ey.?P2(y,x) & ?P3(y,x)))) -> (Ax.Ey.?P1(y,x) & ?P0(y,x))` (post-hoc refuted: False)
* PA/numerals b=400 s=1: Ind:1+MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0*0 & ?P0(x,0)) & (Ax.(Ey.y<x*x & ?P0(y,x)) -> (Ey.?P1(y,x) & ?P2(y,x)))) -> (Ax.Ey.?P3(y,x) & ?P4(y,x))` (post-hoc refuted: False)
* PA/numerals b=400 s=1: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/numerals b=400 s=2: MISTAKE:ind_wrong_concl:2; accepted `(?P0(0) & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P0(Sx))` (post-hoc refuted: False)
* PA/numerals b=400 s=2: U_0add:3+U_add0:1; accepted `0+?f0=?f0` (post-hoc refuted: False)
* PA/numerals b=2000 s=0: MISTAKE:ind_wrong_base:1+MISTAKE:ind_wrong_concl:1; accepted `((Ex.x<0 & ?P0(x)) & (Ax.(Ey.?P1(y,x) & ?P2(y,x)) -> (Ey.?P1(y,Sx) & ?P2(y,Sx)))) -> (Ax.Ey.?P1(y,Sx) & ?P3(y,x))` (post-hoc refuted: False)
* PA/numerals b=2000 s=1: Ind:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0+0 & ?P0(x,0)) & (Ax.(Ey.?P1(y,x) & ?P0(y,x)) -> (Ey.?P2(y,x) & ?P3(y,x)))) -> (Ax.Ey.?P1(y,x) & ?P0(y,x))` (post-hoc refuted: False)
* PA/numerals b=2000 s=1: Ind:1+MISTAKE:ind_wrong_concl:1+MISTAKE:ind_wrong_step:1; accepted `((Ex.x<0*0 & ?P0(x,0)) & (Ax.(Ey.y<x*x & ?P0(y,x)) -> (Ey.?P1(y,x) & ?P2(y,x)))) -> (Ax.Ey.?P3(y,x) & ?P4(y,x))` (post-hoc refuted: False)
* PA/numerals b=2000 s=1: Ind:1+MISTAKE:ind_wrong_concl:1; accepted `(0=S?f0 & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P1(x))` (post-hoc refuted: False)
* PA/numerals b=2000 s=2: MISTAKE:ind_wrong_concl:2; accepted `(?P0(0) & (Ax.?P0(x) -> ?P0(Sx))) -> (Ax.?P0(Sx))` (post-hoc refuted: False)
* PA/numerals b=2000 s=2: U_0add:3+U_add0:1; accepted `0+?f0=?f0` (post-hoc refuted: False)
* ZF b=80 s=0: MISTAKE:sep_capture:1+Sep:2; accepted `Ax.Ey.Az.z in y <-> (z in x & (Au.?P0(u,z,y,x)))` (post-hoc refuted: True, `Ax.Ey.Az.z in y <-> (z in x & (Au.~z in y))`)
* ZF b=80 s=1: MISTAKE:sep_capture:1+Sep:1; accepted `Ax.Ey.Az.z in y <-> (z in x & (Au.?P0(u,y) -> ?P1(u,z,y)))` (post-hoc refuted: True, `Ax.Ey.Az.z in y <-> (z in x & (Au.w0 in y -> ~(Av.v=v)))`)
* ZF b=80 s=1: MISTAKE:sep_capture:1+Sep:1; accepted `Ax.Ey.Az.z in y <-> (z in x & (?P0(z,y) \| ?P1(z,y,x)))` (post-hoc refuted: True, `Ax.Ey.Az.z in y <-> (z in x & (~z in y \| ~(Au.u=u)))`)
* ZF b=80 s=1: EInd:1+MISTAKE:eind_wrong:1; accepted `(Ax.?P0(x) -> x=x) -> (Ax.x=x)` (post-hoc refuted: False)
* ZF b=80 s=2: MISTAKE:sep_capture:1+Sep:1; accepted `Ax.Ey.Az.z in y <-> (z in x & (?P0(z,y) -> ?P1(z,x)))` (post-hoc refuted: True, `Ax.Ey.Az.z in y <-> (z in x & (z in y -> ~(Au.u=u)))`)
* ZF b=80 s=2: MISTAKE:sep_capture:1+Sep:1; accepted `Ax.Ey.Az.z in y <-> (z in x & (?P0(z,x) & ?P1(z,y)))` (post-hoc refuted: True, `Ax.Ey.Az.z in y <-> (z in x & ((Au.u=u) & ~z in y))`)
* ZF b=400 s=1: EInd:1+MISTAKE:eind_wrong:1; accepted `(Ax.?P0(x) -> x=x) -> (Ax.x=x)` (post-hoc refuted: False)

## (c) Unequal frequencies

PA: Ind 60, x+0=x 20, x*0=0 3, 0+x=x 1, Q axioms 1 each. ZF: Sep 30, Rep 4, EInd 1, axioms 1 each.

| lang | seed | ARI | schemas: n, exact? (DTRC+share exact?), held-out accepted | probes/non-target/refuted | time |
|---|---|---|---|---|---|
| PA | 0 | 1.0 | Ind n=60 E(share: E) 40/40; U_add0 n=20 -(share: E) 14/20; U_mul0 n=3 E(share: E) 20/20 | 45/0/0 | 1.35 |
| PA | 1 | 1.0 | Ind n=60 E(share: E) 40/40; U_add0 n=20 -(share: -) 13/20; U_mul0 n=3 E(share: E) 20/20; U_0add n=1 -(share: -) 0/20 | 40/0/0 | 1.09 |
| PA | 2 | 1.0 | Ind n=60 E(share: E) 40/40; U_add0 n=20 E(share: E) 20/20; U_mul0 n=3 -(share: -) 15/20; U_0add n=1 -(share: -) 0/20 | 40/0/0 | 1.32 |
| ZF | 0 | 1.0 | Sep n=30 E(share: E) 30/30; Rep n=4 E(share: E) 30/30; EInd n=1 -(share: -) 0/30 | 47/0/0 | 5.3 |
| ZF | 1 | 1.0 | Sep n=30 E(share: E) 30/30; Rep n=4 -(share: -) 12/30; EInd n=1 -(share: -) 0/30 | 47/0/0 | 4.68 |
| ZF | 2 | 1.0 | Sep n=30 E(share: E) 30/30; Rep n=4 E(share: E) 30/30; EInd n=1 -(share: -) 0/30 | 47/0/0 | 3.62 |

Wall time: 138.3s
