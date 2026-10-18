# Independent audit: optimized prefix budget and Boolean blocking

Reviewed by the critical-depth agent, 2026-10-19.

Source: `source/critical-optimized-circuit-blocking.tex` in this round8 directory.

SHA256: `0c83d78ae1f387e590de0e7f4eaf8a4253209b234b376e534a30f0fe76dbe255`.

The mathematical argument passes. In particular:

- The stage budget eta=q/L is at most one, and `r_j=eta r_{j-1}/(4C_jP_j)` ensures valid mixture weights and positive constant diagonals. Total prefix entropy q^2/L is permitted by the arbitrary-prefix steering theorem; there is no hidden requirement that it be O(1/L) or bounded by a constant.
- T is at least q, log d and log(2L), so the stated sufficiently large constant in L>=C T provides both remaining depth and steering hypotheses. The output rate and sample exponent absorb q^2/L and all polynomial prefactors correctly, including rate a if it grows with q.
- A b-layer fan-in-two block depends on at most 2^b entrance signals per output. A DNF of at most 2^{2^b} terms uses two threshold stages. The exact local-feature repair polynomial depends on gate fan-in and coefficient norm; its logarithm is O(2^b), including the possibly huge OR fan-in. It does not depend on the entire state width except through the separate mixture factor C_j.
- The adaptive block choice has 2^b<=a+2 and k<=1+h/b. The inequality log(2+L/k)<=log b+log(2+L/h) is valid because k>=h/b and b>=1. This yields the displayed T_*.
- Formula balancing via a subformula of balanced size gives polynomial circuit size and logarithmic depth; the output may be a circuit even if the starting object is a formula, which is sufficient here.
- Fixed-width branching-program transition matrices can be multiplied in a balanced tree with polynomial size and logarithmic depth. The distinction between the work register and the input-query information is correctly preserved.

The claimed sample threshold uses the existing finite-cube rate-sublevel counting theorem, so no additional VC log(1/epsilon) factor is missing. The width threshold is qualitative and uniform over the realized sample exactly as stated in that theorem.

No correction was requested. This remains a quasipolynomial improvement for general formulas and fixed-width branching programs, rather than a jointly polynomial theorem for all such targets.
