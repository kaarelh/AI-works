# E4: stress sets

Command: `python3 experiments/e4_stress.py`; seeds [0, 1, 2].

## (a) Near-miss targets

PA targets: U_add0 = `?t+0=?t`, U_add1 = `?t+1=S?t`, U_mul1 = `?t*1=?t`, U_0add = `0+?t=?t`, U_add00 = `?t+0+0=?t+0`, Ind = `(?P(0) & (Ax.?P(x) -> ?P(Sx))) -> (Ax.?P(x))`, IndSwap = `((Ax.?P(x) -> ?P(Sx)) & ?P(0)) -> (Ax.?P(x))`, IndCurry = `?P(0) -> ((Ax.?P(x) -> ?P(Sx)) -> (Ax.?P(x)))`

ZF targets: Sep = `Ax.Ey.Az.z in y <-> (z in x & ?P(z,x))`, SepSwap = `Ax.Ey.Az.z in y <-> (?P(z,x) & z in x)`, Rep = `Ax.(Ay.y in x -> (Ez.?P(y,z,x) & (Au.?P(y,u,x) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ?P(u,z,x)))`, EInd = `(Ax.(Ay.y in x -> ?P(y)) -> ?P(x)) -> (Ax.?P(x))`, FoundS = `(Ex.?P(x)) -> (Ex.?P(x) & (Ay.y in x -> ~?P(y)))`, Found = `Ax.(Ey.y in x) -> (Ey.y in x & (Az.z in y -> ~z in x))`

| lang | seed | ARI | clusters | exact | targets | mixed clusters (label:count) | not exact | probes/non-target/refuted | oracle calls | time |
|---|---|---|---|---|---|---|---|---|---|---|
| PA | 0 | 0.923 | 9 | 7 | 8 | U_add0:5+U_add00:6; U_0add:1+U_add1:6; U_add0:1+U_add1:1; U_add0:1+U_add1:1 | U_add00 | 97/4/0 | 860 | 0.47 |
| PA | 1 | 1.0 | 7 | 7 | 8 | U_add0:8+U_add00:7; U_0add:1+U_add1:8; U_0add:5+U_add0:1 | U_add00 | 93/0/0 | 771 | 0.39 |
| PA | 2 | 1.0 | 7 | 6 | 8 | U_0add:1+U_add0:6+U_add00:7; U_0add:1+U_add1:6 | U_0add, U_add00 | 88/0/0 | 680 | 0.81 |
| ZF | 0 | 1.0 | 6 | 6 | 6 | none | - | 93/0/0 | 968 | 5.5 |
| ZF | 1 | 1.0 | 6 | 6 | 6 | none | - | 89/0/0 | 785 | 4.66 |
| ZF | 2 | 1.0 | 6 | 6 | 6 | none | - | 93/0/0 | 925 | 4.87 |

## (b) Injected mistakes

PA: 8 mistakes (wrong step clause phi(x)->phi(x); wrong base phi(S0); conclusion Ax phi(Sx) (true, non-instance); n+0=0) + 3 true non-target sentences. ZF: 6 mistakes (Separation with b free in phi; Ax(phi->phi)->Ax phi; complement comprehension).

| refuter budget | lang | seed | ARI (clean data) | exact targets | held-out accepted | fate of mistakes | probes/non-target/refuted | oracle calls | time |
|---|---|---|---|---|---|---|---|---|---|
| 80 | PA | 0 | 1.0 | 11/11 | 107/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 7 | 74/27/0 | 1239 | 0.74 |
| 80 | PA | 1 | 0.9047 | 11/11 | 107/107 | discarded (refuted): 2; merged into Ind: 1; singleton cluster: 8 | 76/28/0 | 1026 | 0.56 |
| 80 | PA | 2 | 0.9474 | 11/11 | 107/107 | discarded (refuted): 3; merged into Ind: 1; singleton cluster: 7 | 75/27/0 | 908 | 0.63 |
| 80 | ZF | 0 | 0.9507 | 9/9 | 96/96 | discarded (refuted): 3; merged into Sep: 1; singleton cluster: 1 | 85/9/0 | 959 | 6.2 |
| 80 | ZF | 1 | 0.8673 | 9/9 | 96/96 | discarded (refuted): 2; merged into EInd: 1; merged into Sep: 2 | 118/44/0 | 1003 | 6.35 |
| 80 | ZF | 2 | 0.8994 | 9/9 | 96/96 | discarded (refuted): 3; merged into Sep: 2 | 102/18/0 | 1015 | 6.81 |
| 400 | PA | 0 | 1.0 | 11/11 | 107/107 | discarded (refuted): 2; merged into MISTAKE:ind_wrong_concl: 1; merged into MISTAKE:ind_wrong_step: 1; singleton cluster: 7 | 74/27/0 | 2953 | 2.83 |
| 400 | PA | 1 | 0.9047 | 11/11 | 107/107 | discarded (refuted): 2; merged into Ind: 1; singleton cluster: 8 | 76/28/0 | 2129 | 0.92 |
| 400 | PA | 2 | 0.9474 | 11/11 | 107/107 | discarded (refuted): 3; merged into Ind: 1; singleton cluster: 7 | 75/27/0 | 2013 | 1.05 |
| 400 | ZF | 0 | 0.9507 | 9/9 | 96/96 | discarded (refuted): 3; merged into Sep: 1; singleton cluster: 1 | 85/9/0 | 2578 | 19.73 |
| 400 | ZF | 1 | 0.9121 | 9/9 | 96/96 | discarded (refuted): 2; merged into EInd: 1; merged into Sep: 1; singleton cluster: 1 | 100/31/0 | 2869 | 19.67 |
| 400 | ZF | 2 | 1.0 | 9/9 | 96/96 | discarded (refuted): 3; singleton cluster: 2 | 66/2/0 | 2983 | 21.81 |

## (c) Unequal frequencies

PA: Ind 60, x+0=x 20, x*0=0 3, 0+x=x 1, Q axioms 1 each. ZF: Sep 30, Rep 4, EInd 1, axioms 1 each.

| lang | seed | ARI | schemas: n, exact?, held-out accepted | probes/non-target/refuted | time |
|---|---|---|---|---|---|
| PA | 0 | 1.0 | Ind n=60 E 40/40; U_add0 n=20 E 20/20; U_mul0 n=3 E 20/20; U_0add n=1 - 4/20 | 45/0/0 | 0.99 |
| PA | 1 | 1.0 | Ind n=60 E 40/40; U_add0 n=20 E 20/20; U_mul0 n=3 - 14/20 | 45/0/0 | 1.05 |
| PA | 2 | 1.0 | Ind n=60 E 40/40; U_add0 n=20 E 20/20; U_mul0 n=3 E 20/20 | 48/0/0 | 1.14 |
| ZF | 0 | 1.0 | Sep n=30 E 30/30; Rep n=4 E 30/30; EInd n=1 - 0/30 | 47/0/0 | 6.63 |
| ZF | 1 | 1.0 | Sep n=30 E 30/30; Rep n=4 - 15/30; EInd n=1 - 0/30 | 47/0/0 | 6.74 |
| ZF | 2 | 1.0 | Sep n=30 E 30/30; Rep n=4 E 30/30; EInd n=1 - 0/30 | 47/0/0 | 6.54 |

Wall time: 128.5s
