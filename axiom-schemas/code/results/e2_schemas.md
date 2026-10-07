# E2: learning each ZF schema (and PA induction) from tagged instances (Q2)

Command: `python3 experiments/e2_schemas.py`; 30 seeds per N (exactness), 8 seeds (probes).

## Exactness (acceptance set = inst(target))

DT°_F and pattern columns: exact (acceptance set equals inst(target), syntactic test). First-order columns: *complete* (accepts all of 30 held-out genuine instances); their soundness is measured by the probes below.

| schema | N | DT°_F exact | DT°_F + refutation exact | pattern lgg (genuine) exact | pattern lgg (formula-level, v1) exact | fo-lgg named complete | fo-lgg de Bruijn complete |
|---|---|---|---|---|---|---|---|
| Sep | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Sep | 2 | 23/30 | 23/30 | 23/30 | 23/30 | 25/30 | 25/30 |
| Sep | 3 | 27/30 | 27/30 | 27/30 | 27/30 | 28/30 | 28/30 |
| Sep | 4 | 28/30 | 28/30 | 28/30 | 28/30 | 28/30 | 28/30 |
| Sep | 6 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Sep | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Rep | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Rep | 2 | 23/30 | 23/30 | 23/30 | 23/30 | 28/30 | 28/30 |
| Rep | 3 | 24/30 | 24/30 | 24/30 | 24/30 | 28/30 | 28/30 |
| Rep | 4 | 26/30 | 26/30 | 26/30 | 26/30 | 30/30 | 30/30 |
| Rep | 6 | 28/30 | 28/30 | 28/30 | 28/30 | 30/30 | 30/30 |
| Rep | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| EInd | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| EInd | 2 | 27/30 | 27/30 | 24/30 | 27/30 | 24/30 | 24/30 |
| EInd | 3 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 |
| EInd | 4 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 |
| EInd | 6 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| EInd | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Ind | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Ind | 2 | 25/30 | 27/30 | 0/30 | 0/30 | 25/30 | 25/30 |
| Ind | 3 | 30/30 | 30/30 | 0/30 | 0/30 | 30/30 | 30/30 |
| Ind | 4 | 30/30 | 30/30 | 0/30 | 0/30 | 30/30 | 30/30 |
| Ind | 6 | 30/30 | 30/30 | 0/30 | 0/30 | 30/30 | 30/30 |
| Ind | 8 | 30/30 | 30/30 | 0/30 | 0/30 | 30/30 | 30/30 |

## Soundness probes (30 sampled accepted sentences per hypothesis and seed)

| schema | N | learner | probes | instances of no target | refuted by oracle |
|---|---|---|---|---|---|
| Sep | 2 | DT°_F | 98 | 0 | 0 |
| Sep | 2 | pattern | 96 | 0 | 0 |
| Sep | 2 | pattern (formula-level) | 104 | 0 | 0 |
| Sep | 2 | fo-named | 154 | 62 | 6 |
| Sep | 2 | fo-deBruijn | 153 | 59 | 6 |
| Sep | 6 | DT°_F | 134 | 0 | 0 |
| Sep | 6 | pattern | 133 | 0 | 0 |
| Sep | 6 | pattern (formula-level) | 142 | 0 | 0 |
| Sep | 6 | fo-named | 176 | 72 | 7 |
| Sep | 6 | fo-deBruijn | 178 | 66 | 5 |
| Rep | 2 | DT°_F | 130 | 0 | 0 |
| Rep | 2 | pattern | 127 | 0 | 0 |
| Rep | 2 | pattern (formula-level) | 142 | 0 | 0 |
| Rep | 2 | fo-named | 240 | 240 | 12 |
| Rep | 2 | fo-deBruijn | 240 | 240 | 18 |
| Rep | 6 | DT°_F | 157 | 0 | 0 |
| Rep | 6 | pattern | 154 | 0 | 0 |
| Rep | 6 | pattern (formula-level) | 133 | 0 | 0 |
| Rep | 6 | fo-named | 240 | 240 | 17 |
| Rep | 6 | fo-deBruijn | 240 | 240 | 17 |
| EInd | 2 | DT°_F | 80 | 0 | 0 |
| EInd | 2 | pattern | 83 | 0 | 0 |
| EInd | 2 | pattern (formula-level) | 76 | 0 | 0 |
| EInd | 2 | fo-named | 204 | 195 | 11 |
| EInd | 2 | fo-deBruijn | 84 | 0 | 0 |
| EInd | 6 | DT°_F | 120 | 0 | 0 |
| EInd | 6 | pattern | 115 | 0 | 0 |
| EInd | 6 | pattern (formula-level) | 113 | 0 | 0 |
| EInd | 6 | fo-named | 230 | 219 | 11 |
| EInd | 6 | fo-deBruijn | 98 | 0 | 0 |
| Ind | 2 | DT°_F | 85 | 0 | 0 |
| Ind | 2 | pattern | 229 | 224 | 58 |
| Ind | 2 | pattern (formula-level) | 220 | 213 | 46 |
| Ind | 2 | fo-named | 240 | 239 | 91 |
| Ind | 2 | fo-deBruijn | 240 | 240 | 87 |
| Ind | 6 | DT°_F | 123 | 0 | 0 |
| Ind | 6 | pattern | 239 | 237 | 70 |
| Ind | 6 | pattern (formula-level) | 239 | 237 | 61 |
| Ind | 6 | fo-named | 240 | 240 | 90 |
| Ind | 6 | fo-deBruijn | 240 | 240 | 78 |

## Exhibits: accepted sentences certified false by the oracle

* Sep, fo-named, N=2: `Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`
* Sep, fo-deBruijn, N=2: `Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`
* Rep, fo-named, N=2: `Ax.(Ay.y in x -> (Ez.(Au.u=u) & (Au.~(Av.v=v) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~x in x))`
* Rep, fo-deBruijn, N=2: `Ax.(Ay.y in x -> (Ez.y in x & (Au.~(Av.v=v) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & (Av.v=v)))`
* EInd, fo-named, N=2: `(Ax.(Ay.y in x -> x=y) -> ~x in w0) -> (Ax.~x in w0)`
* Ind, pattern, N=2: `(0=0 & (Ax.w0=Sx+(0+x) -> 0=1*Sx)) -> (Ax.w0=Sx+(0+x))`
* Ind, pattern (formula-level), N=2: `(0+1=1+(0+0) & (Ax.x=1 -> ~x=w0)) -> (Ax.x=1)`
* Ind, fo-named, N=2: `(w0=0 & (Ax.0=x -> w0=0)) -> (Ax.0=x)`
* Ind, fo-deBruijn, N=2: `(0=w0 & (Ax.x=0 -> 0=x)) -> (Ax.x=0)`

Refuter stats: ZF {'oracle_calls': 2421, 'templates_tested': 107, 'oracle_time': 14.465, 'refuter_time': 15.634}; PA {'oracle_calls': 809, 'templates_tested': 36, 'oracle_time': 1.221, 'refuter_time': 1.773}

Min is the alignment-complete Min^al; it differed from the literal Min on 0 of the 720 data sets.

Wall time: 32.9s
