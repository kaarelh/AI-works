# E3: DTRC on untagged mixtures (Q3), v2

Command: `python3 experiments/e3_mix.py`; seeds [0, 1, 2, 3, 4]. Exactness is split into schema-level targets (with metavariables: Ind and the three ?t-instance schemas; Sep, Rep, EInd) and single ground axioms (exact = kept as a singleton cluster accepting exactly the axiom). Held-out sets contain schema instances only and are disjoint from the training data. "refuted" counts accepted non-target sentences certified false by the oracle: a lower bound on unsoundness.

## PA-mix, universal axioms through numerals only (main regime)

Totals over the 5 seeds:

| learner | mean ARI | schema targets exact | single axioms exact | held-out schema instances accepted | probes / non-target / refuted |
|---|---|---|---|---|---|
| DTRC | 1.000 | 13/20 | 35/35 | 451/500 | 226/0/0 |
| DTRC+share | 1.000 | 17/20 | 35/35 | 474/500 | 227/0/0 |
| skeleton(k) | 0.993 | 9/20 | 29/35 | 425/500 | 282/68/64 |
| tagged (gold labels) | - | 13/20 | 35/35 | - | - |
| tagged (membership) | - | 17/20 | 35/35 | - | - |
| fo-lgg/tag named | - | - | - | 453/500 | 180/100/28 |
| fo-lgg/tag debruijn | - | - | - | 453/500 | 180/100/28 |
| pattern-lgg/tag (genuine) | - | 8/20 | - | 453/500 | 221/99/33 |
| pattern-lgg/tag (formula-level, v1) | - | 8/20 | - | 453/500 | 221/99/33 |

Schema targets, exact per seed (E = exact, - = not), seeds [0, 1, 2, 3, 4]:

| target | DTRC | DTRC+share | tagged (gold) | tagged (membership) |
|---|---|---|---|---|
| Ind | EEEEE | EEEEE | EEEEE | EEEEE |
| U_add0 | ----E | EEE-E | -EE-E | EEE-E |
| U_mul0 | -EEEE | -EEEE | -EEEE | -EEEE |
| U_0add | EEE-- | EEE-E | E---- | EEE-E |

Per seed:

| seed | learner | ARI | clusters | schema exact | axioms exact | held-out accepted | probes | non-target | refuted | oracle calls | time (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | DTRC | 1.0 | 11 | 2/4 | 7/7 | 86/100 | 45 | 0 | 0 | 763 | 0.6 |
| 0 | DTRC+share | 1.0 | 11 | 3/4 | 7/7 | 92/100 | 46 | 0 | 0 | 773 | 0.68 |
| 0 | skeleton(k) | 0.9982 | 11 | 1/4 | 5/7 | 77/100 | 60 | 16 | 15 | 0 | 0.06 |
| 0 | tagged (gold labels) | - | - | 2/4 | 7/7 | - | - | - | - | - | - |
| 0 | tagged (membership) | - | - | 3/4 | 7/7 | - | - | - | - | - | - |
| 0 | fo-lgg/tag named | - | - | - | - | 86/100 | 36 | 20 | 7 | - | - |
| 0 | fo-lgg/tag debruijn | - | - | - | - | 86/100 | 36 | 20 | 7 | - | - |
| 0 | pattern-lgg/tag (genuine) | - | - | 1/4 | - | 86/100 | 44 | 20 | 8 | - | - |
| 0 | pattern-lgg/tag (formula-level, v1) | - | - | 1/4 | - | 86/100 | 44 | 20 | 8 | - | - |
| 1 | DTRC | 1.0 | 11 | 3/4 | 7/7 | 94/100 | 46 | 0 | 0 | 662 | 0.42 |
| 1 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 46 | 0 | 0 | 671 | 0.55 |
| 1 | skeleton(k) | 0.9982 | 11 | 2/4 | 5/7 | 90/100 | 61 | 16 | 15 | 0 | 0.05 |
| 1 | tagged (gold labels) | - | - | 3/4 | 7/7 | - | - | - | - | - | - |
| 1 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 1 | fo-lgg/tag named | - | - | - | - | 96/100 | 36 | 20 | 7 | - | - |
| 1 | fo-lgg/tag debruijn | - | - | - | - | 96/100 | 36 | 20 | 7 | - | - |
| 1 | pattern-lgg/tag (genuine) | - | - | 2/4 | - | 96/100 | 43 | 20 | 5 | - | - |
| 1 | pattern-lgg/tag (formula-level, v1) | - | - | 2/4 | - | 96/100 | 43 | 20 | 5 | - | - |
| 2 | DTRC | 1.0 | 11 | 3/4 | 7/7 | 95/100 | 44 | 0 | 0 | 587 | 0.74 |
| 2 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 44 | 0 | 0 | 599 | 0.77 |
| 2 | skeleton(k) | 0.9724 | 11 | 2/4 | 7/7 | 90/100 | 52 | 18 | 18 | 0 | 0.06 |
| 2 | tagged (gold labels) | - | - | 3/4 | 7/7 | - | - | - | - | - | - |
| 2 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 2 | fo-lgg/tag named | - | - | - | - | 95/100 | 36 | 20 | 4 | - | - |
| 2 | fo-lgg/tag debruijn | - | - | - | - | 95/100 | 36 | 20 | 4 | - | - |
| 2 | pattern-lgg/tag (genuine) | - | - | 2/4 | - | 95/100 | 42 | 19 | 9 | - | - |
| 2 | pattern-lgg/tag (formula-level, v1) | - | - | 2/4 | - | 95/100 | 42 | 19 | 9 | - | - |
| 3 | DTRC | 1.0 | 11 | 2/4 | 7/7 | 82/100 | 44 | 0 | 0 | 967 | 0.78 |
| 3 | DTRC+share | 1.0 | 11 | 2/4 | 7/7 | 82/100 | 44 | 0 | 0 | 967 | 0.87 |
| 3 | skeleton(k) | 1.0 | 11 | 2/4 | 7/7 | 82/100 | 44 | 0 | 0 | 0 | 0.06 |
| 3 | tagged (gold labels) | - | - | 2/4 | 7/7 | - | - | - | - | - | - |
| 3 | tagged (membership) | - | - | 2/4 | 7/7 | - | - | - | - | - | - |
| 3 | fo-lgg/tag named | - | - | - | - | 82/100 | 36 | 20 | 5 | - | - |
| 3 | fo-lgg/tag debruijn | - | - | - | - | 82/100 | 36 | 20 | 5 | - | - |
| 3 | pattern-lgg/tag (genuine) | - | - | 1/4 | - | 82/100 | 44 | 20 | 6 | - | - |
| 3 | pattern-lgg/tag (formula-level, v1) | - | - | 1/4 | - | 82/100 | 44 | 20 | 6 | - | - |
| 4 | DTRC | 1.0 | 11 | 3/4 | 7/7 | 94/100 | 47 | 0 | 0 | 868 | 0.56 |
| 4 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 47 | 0 | 0 | 877 | 0.62 |
| 4 | skeleton(k) | 0.9983 | 11 | 2/4 | 5/7 | 86/100 | 65 | 18 | 16 | 0 | 0.06 |
| 4 | tagged (gold labels) | - | - | 3/4 | 7/7 | - | - | - | - | - | - |
| 4 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 4 | fo-lgg/tag named | - | - | - | - | 94/100 | 36 | 20 | 5 | - | - |
| 4 | fo-lgg/tag debruijn | - | - | - | - | 94/100 | 36 | 20 | 5 | - | - |
| 4 | pattern-lgg/tag (genuine) | - | - | 2/4 | - | 94/100 | 48 | 20 | 5 | - | - |
| 4 | pattern-lgg/tag (formula-level, v1) | - | - | 2/4 | - | 94/100 | 48 | 20 | 5 | - | - |

Min calls where the alignment-complete Min differs from the literal Min (DTRC), per seed: [0, 0, 0, 0, 0]; alignment truncations: [0, 0, 0, 0, 0]; MinCover truncations: [0, 0, 0, 0, 0]; data shared by the sharing pass: [1, 1, 1, 0, 1].

Examples of accepted sentences refuted by the oracle:

* skeleton(k) (seed 0): `Ax.Ay.x<2`
* fo-lgg/tag named (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* fo-lgg/tag debruijn (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* pattern-lgg/tag (genuine) (seed 0): `(w0=0 & (Ax.x=w0 -> x<2)) -> (Ax.x=w0)`
* pattern-lgg/tag (formula-level, v1) (seed 0): `(w0=0 & (Ax.x=w0 -> x<2)) -> (Ax.x=w0)`

## PA-mix, v1 instance distribution (numerals, closed terms, parameter form)

Totals over the 5 seeds:

| learner | mean ARI | schema targets exact | single axioms exact | held-out schema instances accepted | probes / non-target / refuted |
|---|---|---|---|---|---|
| DTRC | 1.000 | 19/20 | 35/35 | 491/500 | 233/0/0 |
| DTRC+share | 1.000 | 20/20 | 35/35 | 500/500 | 234/0/0 |
| skeleton(k) | 0.975 | 17/20 | 23/35 | 481/500 | 416/197/185 |
| tagged (gold labels) | - | 20/20 | 35/35 | - | - |
| tagged (membership) | - | 20/20 | 35/35 | - | - |
| fo-lgg/tag named | - | - | - | 500/500 | 180/100/28 |
| fo-lgg/tag debruijn | - | - | - | 500/500 | 180/100/28 |
| pattern-lgg/tag (genuine) | - | 15/20 | - | 500/500 | 225/99/31 |
| pattern-lgg/tag (formula-level, v1) | - | 15/20 | - | 500/500 | 225/99/31 |

Schema targets, exact per seed (E = exact, - = not), seeds [0, 1, 2, 3, 4]:

| target | DTRC | DTRC+share | tagged (gold) | tagged (membership) |
|---|---|---|---|---|
| Ind | EEEEE | EEEEE | EEEEE | EEEEE |
| U_add0 | EEE-E | EEEEE | EEEEE | EEEEE |
| U_mul0 | EEEEE | EEEEE | EEEEE | EEEEE |
| U_0add | EEEEE | EEEEE | EEEEE | EEEEE |

Per seed:

| seed | learner | ARI | clusters | schema exact | axioms exact | held-out accepted | probes | non-target | refuted | oracle calls | time (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | DTRC | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 47 | 0 | 0 | 760 | 0.64 |
| 0 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 47 | 0 | 0 | 764 | 0.79 |
| 0 | skeleton(k) | 0.9701 | 11 | 4/4 | 3/7 | 100/100 | 109 | 62 | 58 | 0 | 0.06 |
| 0 | tagged (gold labels) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 0 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 0 | fo-lgg/tag named | - | - | - | - | 100/100 | 36 | 20 | 7 | - | - |
| 0 | fo-lgg/tag debruijn | - | - | - | - | 100/100 | 36 | 20 | 7 | - | - |
| 0 | pattern-lgg/tag (genuine) | - | - | 3/4 | - | 100/100 | 46 | 20 | 7 | - | - |
| 0 | pattern-lgg/tag (formula-level, v1) | - | - | 3/4 | - | 100/100 | 46 | 20 | 7 | - | - |
| 1 | DTRC | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 47 | 0 | 0 | 641 | 0.48 |
| 1 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 47 | 0 | 0 | 645 | 0.55 |
| 1 | skeleton(k) | 0.9719 | 11 | 4/4 | 5/7 | 100/100 | 76 | 29 | 28 | 0 | 0.05 |
| 1 | tagged (gold labels) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 1 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 1 | fo-lgg/tag named | - | - | - | - | 100/100 | 36 | 20 | 7 | - | - |
| 1 | fo-lgg/tag debruijn | - | - | - | - | 100/100 | 36 | 20 | 7 | - | - |
| 1 | pattern-lgg/tag (genuine) | - | - | 3/4 | - | 100/100 | 45 | 20 | 7 | - | - |
| 1 | pattern-lgg/tag (formula-level, v1) | - | - | 3/4 | - | 100/100 | 45 | 20 | 7 | - | - |
| 2 | DTRC | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 48 | 0 | 0 | 584 | 0.76 |
| 2 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 48 | 0 | 0 | 588 | 0.82 |
| 2 | skeleton(k) | 0.9659 | 11 | 3/4 | 5/7 | 96/100 | 92 | 53 | 50 | 0 | 0.06 |
| 2 | tagged (gold labels) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 2 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 2 | fo-lgg/tag named | - | - | - | - | 100/100 | 36 | 20 | 4 | - | - |
| 2 | fo-lgg/tag debruijn | - | - | - | - | 100/100 | 36 | 20 | 4 | - | - |
| 2 | pattern-lgg/tag (genuine) | - | - | 3/4 | - | 100/100 | 44 | 19 | 3 | - | - |
| 2 | pattern-lgg/tag (formula-level, v1) | - | - | 3/4 | - | 100/100 | 44 | 19 | 3 | - | - |
| 3 | DTRC | 1.0 | 11 | 3/4 | 7/7 | 91/100 | 45 | 0 | 0 | 975 | 0.78 |
| 3 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 46 | 0 | 0 | 988 | 0.86 |
| 3 | skeleton(k) | 0.9928 | 11 | 3/4 | 5/7 | 91/100 | 65 | 17 | 16 | 0 | 0.07 |
| 3 | tagged (gold labels) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 3 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 3 | fo-lgg/tag named | - | - | - | - | 100/100 | 36 | 20 | 5 | - | - |
| 3 | fo-lgg/tag debruijn | - | - | - | - | 100/100 | 36 | 20 | 5 | - | - |
| 3 | pattern-lgg/tag (genuine) | - | - | 3/4 | - | 100/100 | 45 | 20 | 8 | - | - |
| 3 | pattern-lgg/tag (formula-level, v1) | - | - | 3/4 | - | 100/100 | 45 | 20 | 8 | - | - |
| 4 | DTRC | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 46 | 0 | 0 | 837 | 0.55 |
| 4 | DTRC+share | 1.0 | 11 | 4/4 | 7/7 | 100/100 | 46 | 0 | 0 | 841 | 0.65 |
| 4 | skeleton(k) | 0.9723 | 11 | 3/4 | 5/7 | 94/100 | 74 | 36 | 33 | 0 | 0.06 |
| 4 | tagged (gold labels) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 4 | tagged (membership) | - | - | 4/4 | 7/7 | - | - | - | - | - | - |
| 4 | fo-lgg/tag named | - | - | - | - | 100/100 | 36 | 20 | 5 | - | - |
| 4 | fo-lgg/tag debruijn | - | - | - | - | 100/100 | 36 | 20 | 5 | - | - |
| 4 | pattern-lgg/tag (genuine) | - | - | 3/4 | - | 100/100 | 45 | 20 | 6 | - | - |
| 4 | pattern-lgg/tag (formula-level, v1) | - | - | 3/4 | - | 100/100 | 45 | 20 | 6 | - | - |

Min calls where the alignment-complete Min differs from the literal Min (DTRC), per seed: [0, 0, 0, 0, 0]; alignment truncations: [0, 0, 0, 0, 0]; MinCover truncations: [0, 0, 0, 0, 0]; data shared by the sharing pass: [1, 1, 1, 1, 1].

Examples of accepted sentences refuted by the oracle:

* skeleton(k) (seed 0): `w0+SSSSSS0=SSSSSS0`
* fo-lgg/tag named (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* fo-lgg/tag debruijn (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* pattern-lgg/tag (genuine) (seed 0): `(w0=0 & (Ax.x=w0 -> x<2)) -> (Ax.x=w0)`
* pattern-lgg/tag (formula-level, v1) (seed 0): `(w0=0 & (Ax.x=w0 -> x<2)) -> (Ax.x=w0)`

## ZF-mix

Totals over the 5 seeds:

| learner | mean ARI | schema targets exact | single axioms exact | held-out schema instances accepted | probes / non-target / refuted |
|---|---|---|---|---|---|
| DTRC | 1.000 | 15/15 | 30/30 | 450/450 | 324/0/0 |
| DTRC+share | 1.000 | 15/15 | 30/30 | 450/450 | 324/0/0 |
| skeleton(k) | 1.000 | 15/15 | 30/30 | 450/450 | 324/0/0 |
| tagged (gold labels) | - | 15/15 | 30/30 | - | - |
| tagged (membership) | - | 15/15 | 30/30 | - | - |
| fo-lgg/tag named | - | - | - | 450/450 | 305/223/18 |
| fo-lgg/tag debruijn | - | - | - | 450/450 | 263/128/12 |
| pattern-lgg/tag (genuine) | - | 15/15 | - | 450/450 | 239/0/0 |
| pattern-lgg/tag (formula-level, v1) | - | 15/15 | - | 450/450 | 239/0/0 |

Schema targets, exact per seed (E = exact, - = not), seeds [0, 1, 2, 3, 4]:

| target | DTRC | DTRC+share | tagged (gold) | tagged (membership) |
|---|---|---|---|---|
| Sep | EEEEE | EEEEE | EEEEE | EEEEE |
| Rep | EEEEE | EEEEE | EEEEE | EEEEE |
| EInd | EEEEE | EEEEE | EEEEE | EEEEE |

Per seed:

| seed | learner | ARI | clusters | schema exact | axioms exact | held-out accepted | probes | non-target | refuted | oracle calls | time (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | DTRC | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 691 | 3.97 |
| 0 | DTRC+share | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 691 | 4.35 |
| 0 | skeleton(k) | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 0 | 0.07 |
| 0 | tagged (gold labels) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 0 | tagged (membership) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 0 | fo-lgg/tag named | - | - | - | - | 90/90 | 61 | 44 | 2 | - | - |
| 0 | fo-lgg/tag debruijn | - | - | - | - | 90/90 | 52 | 25 | 1 | - | - |
| 0 | pattern-lgg/tag (genuine) | - | - | 3/3 | - | 90/90 | 51 | 0 | 0 | - | - |
| 0 | pattern-lgg/tag (formula-level, v1) | - | - | 3/3 | - | 90/90 | 51 | 0 | 0 | - | - |
| 1 | DTRC | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 660 | 3.64 |
| 1 | DTRC+share | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 660 | 3.81 |
| 1 | skeleton(k) | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 66 | 0 | 0 | 0 | 0.06 |
| 1 | tagged (gold labels) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 1 | tagged (membership) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 1 | fo-lgg/tag named | - | - | - | - | 90/90 | 62 | 45 | 4 | - | - |
| 1 | fo-lgg/tag debruijn | - | - | - | - | 90/90 | 56 | 25 | 3 | - | - |
| 1 | pattern-lgg/tag (genuine) | - | - | 3/3 | - | 90/90 | 54 | 0 | 0 | - | - |
| 1 | pattern-lgg/tag (formula-level, v1) | - | - | 3/3 | - | 90/90 | 54 | 0 | 0 | - | - |
| 2 | DTRC | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 65 | 0 | 0 | 715 | 3.61 |
| 2 | DTRC+share | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 65 | 0 | 0 | 715 | 4.47 |
| 2 | skeleton(k) | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 65 | 0 | 0 | 0 | 0.04 |
| 2 | tagged (gold labels) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 2 | tagged (membership) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 2 | fo-lgg/tag named | - | - | - | - | 90/90 | 60 | 44 | 4 | - | - |
| 2 | fo-lgg/tag debruijn | - | - | - | - | 90/90 | 51 | 26 | 2 | - | - |
| 2 | pattern-lgg/tag (genuine) | - | - | 3/3 | - | 90/90 | 45 | 0 | 0 | - | - |
| 2 | pattern-lgg/tag (formula-level, v1) | - | - | 3/3 | - | 90/90 | 45 | 0 | 0 | - | - |
| 3 | DTRC | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 63 | 0 | 0 | 682 | 4.5 |
| 3 | DTRC+share | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 63 | 0 | 0 | 682 | 5.47 |
| 3 | skeleton(k) | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 63 | 0 | 0 | 0 | 0.08 |
| 3 | tagged (gold labels) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 3 | tagged (membership) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 3 | fo-lgg/tag named | - | - | - | - | 90/90 | 61 | 45 | 3 | - | - |
| 3 | fo-lgg/tag debruijn | - | - | - | - | 90/90 | 53 | 27 | 3 | - | - |
| 3 | pattern-lgg/tag (genuine) | - | - | 3/3 | - | 90/90 | 43 | 0 | 0 | - | - |
| 3 | pattern-lgg/tag (formula-level, v1) | - | - | 3/3 | - | 90/90 | 43 | 0 | 0 | - | - |
| 4 | DTRC | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 64 | 0 | 0 | 804 | 5.99 |
| 4 | DTRC+share | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 64 | 0 | 0 | 804 | 6.4 |
| 4 | skeleton(k) | 1.0 | 9 | 3/3 | 6/6 | 90/90 | 64 | 0 | 0 | 0 | 0.03 |
| 4 | tagged (gold labels) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 4 | tagged (membership) | - | - | 3/3 | 6/6 | - | - | - | - | - | - |
| 4 | fo-lgg/tag named | - | - | - | - | 90/90 | 61 | 45 | 5 | - | - |
| 4 | fo-lgg/tag debruijn | - | - | - | - | 90/90 | 51 | 25 | 3 | - | - |
| 4 | pattern-lgg/tag (genuine) | - | - | 3/3 | - | 90/90 | 46 | 0 | 0 | - | - |
| 4 | pattern-lgg/tag (formula-level, v1) | - | - | 3/3 | - | 90/90 | 46 | 0 | 0 | - | - |

Min calls where the alignment-complete Min differs from the literal Min (DTRC), per seed: [1, 0, 0, 0, 0]; alignment truncations: [0, 0, 0, 0, 0]; MinCover truncations: [0, 0, 0, 0, 0]; data shared by the sharing pass: [0, 0, 0, 0, 0].

Examples of accepted sentences refuted by the oracle:

* fo-lgg/tag named (seed 0): `Ax.(Ay.y in x -> (Ez.~x in z & (Au.y in z -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~u in u))`
* fo-lgg/tag debruijn (seed 0): `Ax.(Ay.y in x -> (Ez.~x in z & (Au.y in z -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~u in u))`

Wall time: 74.4s
