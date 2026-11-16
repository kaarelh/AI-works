# The lead's harmonisation of the assembled note: exact replacements, each of which must match once.
# Read by assemble.py. Keep the reason next to each pair.

PATCHES = [
    # Section 2: what "very much compute" means.
    (
        "The human answers at most n + m single calls, taken from the imitator's own runs at every depth of a decomposition, and never carries out a run.\n",
        "The human answers at most n + m single calls, taken from the imitator's own runs at every depth of a decomposition, and never carries out a run.\n\n"
        "**Compute.** If the hypotheses are programs that always halt, for instance programs that carry their own time bound, and the weights are 2^(−length) in a decidable prefix-free code, a posterior draw can be made by rejection: read a program from coin flips, run it with fresh coins on the recorded questions, and keep it if it reproduces the recorded answers. A kept program has exactly the posterior law. The expected number of trials is at most 2^K divided by the probability that the human gives the recorded answers; this is the \"very much compute\" of the question. For the class of all programs a trial may not halt; the theorems then concern the mixture as a mathematical object, which can only be approximated from below.\n",
    ),
    # Section 3.2: the middle expression exceeds 2*sqrt(sigma) for large sigma; the proof file has the minimum with 1.
    (
        "(b) TV(Q_A, Q_B) ≤ σ + √(σ² + 2σ) ≤ 2√σ;",
        "(b) TV(Q_A, Q_B) ≤ min{1, σ + √(σ² + 2σ)} ≤ 2√σ;",
    ),
    (
        "(b) TV(Q_{M^(T)}, Q_P) ≤ s + √(s² + 2s) ≤ √(2·L·K ln 2/n), which is at most ε after (1 + ε)·L·K ln 2/ε² rounds;",
        "(b) TV(Q_{M^(T)}, Q_P) ≤ min{1, s + √(s² + 2s)} ≤ √(2·L·K ln 2/n), which is at most ε after (1 + ε)·L·K ln 2/ε² rounds;",
    ),
    (
        "For a deterministic human Theorem R1 settles whole runs: the run of M^(T) is the human system's run on the same (z, ρ), except with probability L·K ln 2/n. For a human who varies, the laws of the runs are compared.",
        "For a deterministic human Theorem R1 settles whole runs: the run of M^(T) is the human system's run on the same (z, ρ), except with probability L·K ln 2/n (`proofs/rehearsal-core.md`, Theorem 7.1). For a human who varies, the laws of the runs are compared.",
    ),
    # Section 3.6: the online form is stated once, as S5 in Section 6.2.
    (
        "### 3.6 The online form\n\nIf every call, as it arrives, is put to the human with probability q and answered by the current mixture otherwise, the expected divergence between human and current mixture, summed over all calls, is at most K ln 2/q, however the questions arise (Theorem 10.1).",
        "### 3.6 Asking while the system runs\n\nIf every call, as it arrives, is put to the human with probability q and answered by the current mixture otherwise, the expected divergence between human and current mixture, summed over all calls, is at most K ln 2/q, however the questions arise (S5, Section 6.2).",
    ),
    # Section 4.5: the constant of R2 improved during verification.
    (
        "By R1 and R2 rehearsal achieves these errors with K ln 2/(2ε²) and 4·L·K ln 2/ε² questions",
        "By R1 and R2 rehearsal achieves these errors with K ln 2/(2ε²) and (1 + ε)·L·K ln 2/ε² questions",
    ),
    # Section 5.1, table: the same constant.
    (
        "| human not deterministic | E TV ≤ 2√(L·K ln 2/n) (R2) |",
        "| human not deterministic | E TV ≤ √(2·L·K ln 2/n) (R2) |",
    ),
    # Section 6.1: "there" is defined in Section 4 only.
    (
        "**What S2 needs** (proved here: Propositions 4.4 and 4.6 there).",
        "**What S2 needs** (proved here: `proofs/lower-bounds.md`, Propositions 4.4 and 4.6).",
    ),
    (
        "With L critical calls per shift it is N·(L/(4δ)−3L/2) (Theorem 4.3 there).",
        "With L critical calls per shift it is N·(L/(4δ)−3L/2) (`proofs/lower-bounds.md`, Theorem 4.3).",
    ),
    # Section 8.1: the same constant of R2.
    (
        "in general E TV ≤ 2√(L·K ln 2/n) (R2);",
        "in general E TV ≤ √(2·L·K ln 2/n) (R2);",
    ),
]
