## 11. A toy closed system

The computations of this section illustrate the theorems on a problem small enough for the Bayes mixture to be computed exactly. They prove nothing. Scripts are in `code/`, outputs in `results/`.

**The system.** The human is the function f(a, b) = (a + b) mod 32. A task is a list of 2^h numbers below 4, and the scaffold adds them in a balanced binary tree, one call for each internal node, so L = 2^h − 1. Calls deep in the tree contain larger numbers than any task does: this is the shift that task decomposition produces. The class has 1117 functions with description-length weights: f; two functions that are simpler than f and agree with it on small numbers ("a + b if both are below 4, else 0", and addition that saturates at 31); 90 guards of the form "f, except another simple function where a simple condition on (a, b) holds"; and 1024 patches that change f at one input. Here K = 3.78 bits.

**Ordinary questions fail; rehearsal does not** (`toy.py`, `results/toy.out`). After 10,000 questions about pairs of numbers below 4, the posterior is where it was after 100: weight 0.59 on the first simpler function, 0.30 on the second, 0.07 on f. The questions cannot separate them. Deployed on the tree, the mixture then has an unfaithful call in 35% of the runs at depth 2, 98% at depth 4 and 100% at depth 6. With rehearsal, the number of unfaithful calls summed over all rehearsal runs stays below the bound L·K ln 2 of Theorem R1 (averages over 60 repetitions):

| depth | L | unfaithful calls, summed over 6400 rounds | bound L·K ln 2 | runs with an unfaithful call, average over 6400 rounds |
|---|---|---|---|---|
| 2 | 3 | 2.3 | 7.9 | 0.0004 |
| 4 | 15 | 21.7 | 39.3 | 0.0025 |
| 6 | 63 | 91.8 | 165.0 | 0.0043 |

With one posterior draw answering each run, the runs with an unfaithful call number 1.6, 15.4 and 22.3 in total, against the bound (2L²/(L + 1))·K ln 2 of Theorem R4 (11.8, 73.7, 325). When the heaviest function consistent with the answers so far answers the runs, they number 3.3, 21.1 and 27.2, against the bound of Proposition R6(a), L times the number of functions heavier than f (6, 30, 126). Only two functions are heavier than f here, so the driver that R6(a) warns against does little harm in this class.

**High stakes and low stakes** (`toy_stakes.py`, `results/toy_stakes.out`). Two systems ask L independent additions of uniform pairs. In the first a run is good only if every answer is the human's; in the second, if at most 5% of the answers differ. Both are answered by the same rehearsed mixture. After 6400 questions the first fails in 0.1%, 1.2% and 11.9% of the runs for L = 16, 256 and 4096; the second in 0.11%, 0.03% and 0.03%, below the bound K ln 2/(θn) = 0.82% of Theorem R3, which does not depend on L.

**The certificate** (same script). The mixture frozen after 400 rehearsal questions (L = 256) was put through validation with 1000 further questions, 160 times over. In 140 of the repetitions no recorded pair disagreed, and Theorem V1(a) then certifies a rate of unfaithful calls of at most ln(20)/1000 = 0.003 per call at confidence 95%. The true rate was 0.00014 on average and never above the certified bound.

**An imitator made of tests** (`toy_property.py`, `results/toy_property.out`). The rule with one rate of Section 8.4 was run on a smaller version of the problem (numbers mod 8, depth 3) with 805 tests such as "y − a − b = c", "y = c", "y is even", each also restricted to simple conditions on the input. It has no class of hypotheses. With the deterministic human its audited answers were exact sums in every round of the second half of each experiment. With a human who adds 1 too much with probability 0.1, its answers were exact sums at the rate 0.90, the human's rate, and the largest discrepancy over all tests, |S_n(B)|/n, was 0.0003 after 64,000 rounds (the bound for that test is 0.024). The root of the tree, a property of the whole run, was exact in 62% of its runs against 48% for the human system (57% under Rule NH after 8000 rounds; `proofs/code/property-online_rehearsal.out`): tests of single calls do not control what happens across calls.
