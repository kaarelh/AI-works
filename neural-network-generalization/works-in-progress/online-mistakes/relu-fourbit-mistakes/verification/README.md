# Exact verification of the finite four-bit ReLU theorem

Run with Python, NumPy, and SymPy:

```sh
python verify_d4_foundations.py
python verify_d4_interval_certificates.py
```

Neither checker imports or calls an optimizer. The first verifies the complete activation-cone enumeration, the exact target norm, the sixteen-neuron canonical unit-bounded teacher with margin 21/40, and rational witnesses for all sixteen cheaper one-point corruptions. The second verifies rational norm intervals for all 222 isometry classes and checks all 65,536 Boolean completions along the fixed sequence. It must report 15 strict gaps and a minimum variation gap exceeding 0.01494.

All arithmetic supporting the certificate inequalities is integer, rational, or in the exact quadratic field Q(√15). The checkers bound NumPy integer intermediate magnitudes before their matrix products; arbitrary-size Python integers are used for squared-norm comparisons. Floating fields in the JSON summaries are presentation only.

The target is `g(x)=x1*x2*ANDsign(x3,x4)`. In lexicographic cube indexing with −1 preceding +1, the query order is

`[15,14,13,11,10,9,7,6,3,5,2,8,12,4,1,0]`.

At every fixed width N≥16, the actual globally margin-conditioned Gaussian posterior has error probability tending to one at the last fifteen queries as the prior scale tends to zero. The first sampled prediction is exactly balanced, giving a limiting expected 15.5 mistakes. This is a finite-dimensional theorem; it is not an asymptotic exponential lower bound, and no prior-scale threshold uniform over widths is claimed.

The optional `generation/` scripts record how candidate certificates were produced. They additionally need SciPy and CVXPY with Clarabel. They are unnecessary for verification and are not the source of numerical assumptions in the proof. The stored certificate files are sufficient.

`independent-audit.md` records a separate agent's mathematical audit. This is an exact-arithmetic computer-assisted proof, not a proof-assistant formalization. The accompanying paper states the canonical network normalization and proves the transfer from variation norms to Gaussian posterior probabilities.
