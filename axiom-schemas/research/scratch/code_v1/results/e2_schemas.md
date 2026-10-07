# E2: learning each ZF schema (and PA induction) from tagged instances (Q2)

Command: `python3 experiments/e2_schemas.py`; 30 seeds per N (exactness), 8 seeds (probes).

## Exactness (acceptance set = inst(target))

DT°_F and pattern columns: exact (acceptance set equals inst(target), syntactic test). First-order columns: *complete* (accepts all of 30 held-out genuine instances); their soundness is measured by the probes below.

| schema | N | DT°_F exact | DT°_F + refutation exact | pattern lgg exact | fo-lgg named complete | fo-lgg de Bruijn complete |
|---|---|---|---|---|---|---|
| Sep | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Sep | 2 | 23/30 | 23/30 | 23/30 | 25/30 | 25/30 |
| Sep | 3 | 27/30 | 27/30 | 27/30 | 28/30 | 28/30 |
| Sep | 4 | 28/30 | 28/30 | 28/30 | 28/30 | 28/30 |
| Sep | 6 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Sep | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Rep | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Rep | 2 | 23/30 | 23/30 | 23/30 | 28/30 | 28/30 |
| Rep | 3 | 24/30 | 24/30 | 24/30 | 28/30 | 28/30 |
| Rep | 4 | 26/30 | 26/30 | 26/30 | 30/30 | 30/30 |
| Rep | 6 | 28/30 | 28/30 | 28/30 | 30/30 | 30/30 |
| Rep | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| EInd | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| EInd | 2 | 27/30 | 27/30 | 27/30 | 24/30 | 24/30 |
| EInd | 3 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 |
| EInd | 4 | 29/30 | 29/30 | 29/30 | 29/30 | 29/30 |
| EInd | 6 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| EInd | 8 | 30/30 | 30/30 | 30/30 | 30/30 | 30/30 |
| Ind | 1 | 0/30 | 0/30 | 0/30 | 0/30 | 0/30 |
| Ind | 2 | 25/30 | 27/30 | 0/30 | 25/30 | 25/30 |
| Ind | 3 | 30/30 | 30/30 | 0/30 | 30/30 | 30/30 |
| Ind | 4 | 30/30 | 30/30 | 0/30 | 30/30 | 30/30 |
| Ind | 6 | 30/30 | 30/30 | 0/30 | 30/30 | 30/30 |
| Ind | 8 | 30/30 | 30/30 | 0/30 | 30/30 | 30/30 |

## Soundness probes (30 sampled accepted sentences per hypothesis and seed)

| schema | N | learner | probes | instances of no target | refuted by oracle |
|---|---|---|---|---|---|
| Sep | 2 | DT°_F | 98 | 0 | 0 |
| Sep | 2 | pattern | 96 | 0 | 0 |
| Sep | 2 | fo-named | 150 | 64 | 6 |
| Sep | 2 | fo-deBruijn | 151 | 55 | 5 |
| Sep | 6 | DT°_F | 134 | 0 | 0 |
| Sep | 6 | pattern | 133 | 0 | 0 |
| Sep | 6 | fo-named | 172 | 73 | 7 |
| Sep | 6 | fo-deBruijn | 174 | 65 | 5 |
| Rep | 2 | DT°_F | 130 | 0 | 0 |
| Rep | 2 | pattern | 141 | 0 | 0 |
| Rep | 2 | fo-named | 240 | 240 | 5 |
| Rep | 2 | fo-deBruijn | 240 | 240 | 12 |
| Rep | 6 | DT°_F | 157 | 0 | 0 |
| Rep | 6 | pattern | 154 | 0 | 0 |
| Rep | 6 | fo-named | 240 | 240 | 8 |
| Rep | 6 | fo-deBruijn | 239 | 239 | 13 |
| EInd | 2 | DT°_F | 80 | 0 | 0 |
| EInd | 2 | pattern | 83 | 0 | 0 |
| EInd | 2 | fo-named | 203 | 193 | 8 |
| EInd | 2 | fo-deBruijn | 87 | 0 | 0 |
| EInd | 6 | DT°_F | 120 | 0 | 0 |
| EInd | 6 | pattern | 115 | 0 | 0 |
| EInd | 6 | fo-named | 229 | 219 | 10 |
| EInd | 6 | fo-deBruijn | 96 | 0 | 0 |
| Ind | 2 | DT°_F | 82 | 0 | 0 |
| Ind | 2 | pattern | 229 | 224 | 53 |
| Ind | 2 | fo-named | 240 | 240 | 89 |
| Ind | 2 | fo-deBruijn | 239 | 239 | 85 |
| Ind | 6 | DT°_F | 131 | 0 | 0 |
| Ind | 6 | pattern | 239 | 238 | 54 |
| Ind | 6 | fo-named | 240 | 238 | 80 |
| Ind | 6 | fo-deBruijn | 239 | 239 | 77 |

## Exhibits: accepted sentences certified false by the oracle

* Sep, fo-named, N=2: `Ax.Ey.Az.z in y <-> (z in x & ~z in y)`
* Sep, fo-deBruijn, N=2: `Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`
* Rep, fo-named, N=2: `Ax.(Ay.y in x -> (Ez.x=x & (Au.u=w0 -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~w0 in u))`
* Rep, fo-deBruijn, N=2: `Ax.(Ay.y in x -> (Ez.(Au.u=u) & (Au.~(Av.v=v) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~x in x))`
* EInd, fo-named, N=2: `(Ax.(Ay.y in x -> y in w0) -> ~x in w0) -> (Ax.~x in w0)`
* Ind, pattern, N=2: `(0+1=1+(0+0) & (Ax.x<w0 -> 0=SSx+(0+Sx))) -> (Ax.x<w0)`
* Ind, fo-named, N=2: `(1=w0 & (Ax.w0=Sx -> Sx=Sx)) -> (Ax.w0=Sx)`
* Ind, fo-deBruijn, N=2: `(w0=0 & (Ax.1=w0 -> 0=Sx)) -> (Ax.1=w0)`

Refuter stats: ZF {'oracle_calls': 2602, 'templates_tested': 107, 'oracle_time': 19.256, 'refuter_time': 20.638}; PA {'oracle_calls': 836, 'templates_tested': 36, 'oracle_time': 0.567, 'refuter_time': 1.098}

Wall time: 38.9s
