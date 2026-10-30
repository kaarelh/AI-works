# Mathematical review and publication checks

Research draft, 30 October 2026. [Paper](../paper.pdf) · [source](../source/paper.tex)

The proofs are conventional mathematical proofs, **not Lean formalizations or human peer review**. Several independent AI-agent reviews checked the arguments below; a final review also checked the integrated manuscript for a reader unfamiliar with the repository.

## Main checks

- **Existing AND ladder.** Compared with the existing Solomonoff operator-induction manuscript and checked exact minimality over all binary-gate circuits, including sharing and constants. A support argument replaces the earlier algebraic proof. The mandatory-output-gate convention requires starting the forced-mistake count at Hamming weight two, giving `2^d−d−2`.
- **NAND extension.** Independently checked the retained proof DAG: each true NAND chooses one false child, each false NAND keeps both true children. With `T` true gates, `F` false gates and `R` source leaves, `F≤T` and connectedness gives `R≤F+1≤floor(s/2)+1`. This supplies a positive certificate, proves exact AND complexity `2d−2`, and establishes the same exponential mistake count for actual minimum NAND circuits.
- **Quantifiers.** The bad permutation depends on a deterministic history-based selector and can be precomputed. It does not defeat every tie rule simultaneously, a fresh private randomized selector, or all query-dependent choices of a minimum circuit. Gate count and literal gate-list bit length are distinguished.
- **Fresh uniform minimum circuits.** At each current minimum size, nonexhausting label updates charge their error probability to the logarithmic survivor-count decrease. Exhausting a size costs one. Summing over sizes up to the target gives a pathwise bound on the sum of conditional error probabilities. Conditional Bernoulli exponential moments give the infinite-horizon tail bound. The description counts use the paper's mandatory-final-gate convention.
- **Randomized Hamming levels.** For the AND-containing bases, exact minimality forces the current function to be a surviving conjunction. Randomizing either the input order within a level or the fresh circuit selection gives error probability `1/m` with `m` remaining supports. This proves the harmonic sums and `Θ(d²)` expectation. No corresponding classification of all minimum NAND functions is assumed.
- **Interleaved environments.** Verified the survival union bounds, source-local counters, adaptive scheduler quantifiers, random-order finite-pool factor, iid disagreement-gap integral, and stopped-process high-probability bounds. Sources with identically zero disagreement are omitted before allocating logarithmic probability budgets. Current-input-dependent hypothesis selection is excluded from these particular theorems.
- **Persistent-reference drift.** Checked adaptive survival under the lower density bound, risk control under the upper bound, integration across the positive risk gap, and the summable additive-departure supermartingale. The density assumptions condition on all randomness already used to select the current hypothesis.
- **Near-uniform counterexample.** Checked the reservoir warmup, exact minimum functions, predictable choice of the next-input law, constant conditional hazard of eliminating one surviving conjunction, Hoeffding constants, drift count for fixed rankings, and deterministic exponential horizon. It permits repeated inputs. The current statement uses `d` divisible by four and `k=3d/4`, avoiding the size-zero convention at `k=1`.
- **Genericity.** Verified the expectation and exponential-supermartingale bounds. The assumption is explicitly `0<c≤1` and refers to surviving descriptions, not previously eliminated candidates. It remains a conditional theorem, not a proved typicality statement for real-world data.

## Computational checks

Run `python verification/audit_checks.py` from the paper directory. [Recorded output and coverage](audit_checks_output.txt):

- 640 finite-class target/tier cases, using exact rational dynamic programming over every distinct-query order on a four-point domain.
- 2,795 seeded random NAND DAGs with true output at the all-ones input, checking certificate size and every completion of the certificate by exhaustive evaluation. The generated DAGs allow sharing, repeated inputs, constants, and dead gates.
- Exact shared-DAG enumeration for the minimum NAND sizes of two- and three-variable AND, yielding two and four gates.

These finite checks support the review but do not prove the general theorems. The script uses seed `301026`; it needs only Python's standard library.

The [publication record](record.json) records source and PDF hashes, the isolated rebuild, LaTeX diagnostics, collection links, and preservation of existing Lean sources. The final PDF's title/abstract and theorem pages were also visually inspected. No earlier manuscript's mathematical source or PDF was changed.
