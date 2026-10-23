# Continuous-domain regression: literal main-theorem map

Manuscript: `side-results/continuous-domains/source/paper.tex`.

Both headline main statements are proved with the actual network, prior and
posterior. The shared statement file is `BatchTwoContinuousStatements.lean`.

| Manuscript statement | Checked Lean endpoint |
| --- | --- |
| Strong-prior regression, Theorem `thm:strong` | `BatchTwoContinuousStrongMain.strongPriorRegression : StrongPriorRegression` |
| Finite-scale regression, Theorem `thm:finite`, every gamma ≥ 1 | `BatchTwoContinuousFiniteMain.finiteScaleRegression : FiniteScaleRegression` |
| Finite-scale endpoint gamma = 1 | `BatchTwoContinuousFiniteMeanFieldMain.FiniteMeanField.meanField` |
| Finite-scale gamma > 1 | `BatchTwoContinuousAboveMain.Above.aboveMeanField` |

The finite-scale theorem quantifies over every fixed depth, actual coordinate
law, teacher width C, teacher coordinate bound B, compact nonempty unit-ball
input domain X, learner width N ≥ C, and probability distribution supported on
X. The actual posterior conditions on training output tolerance rho. Its risk
at the larger tolerance tau is at most epsilon/3 and its posterior-confidence
failure mass is at most epsilon, with sample probability at least 1-delta.
The polynomial envelope is proved independently of learner width. Its arguments
include inverse (tau-rho), log inverse training tolerance, and log inverse
epsilon. No first-layer Gaussian replacement is assumed at mean field.

## Finite-scale proof components

- `FiniteTarget.powerPrior_uniformTube_mass` gives a true lower bound for a
  uniform teacher tube at every N ≥ C. `targetCost_polynomial_envelope` proves
  polynomial cost in d,C,B and log inverse tolerance. Even clone groups use an
  independently proved collision small-ball estimate; singleton groups cover
  the widths below 2C. There is no inverse-tolerance cutoff hidden in the cost.
- The gamma > 1 large-width branch uses the actual spectral truncation cover;
  the bounded-width branch uses the actual full-energy tail.
- The gamma = 1 branch proves actual finite-real-query coefficient tails,
  extracts covariance certificates, retains the non-Gaussian first feature
  law, uses proved Lindeberg replacement only for later layers, realizes the
  resulting tower, and proves an approximate regression dual readout.
- A proved input-stability event extends the finite-query approximation to
  the whole domain via measurable nearest-query piecewise extensions. These
  extensions are the counted comparison functions; they need not themselves
  be neural networks. The actual learner and posterior remain neural-network
  objects. Their excluded mass and cover entropy are both proved.
- Polynomial arithmetic and the bounded-width energy fallback complete the
  all-width theorem through the common posterior survival argument.

## Ancillary statements

The root's exact-interpolant corollary is also compiled. The later weak-limit
and classification corollaries have not yet all been formalized. The compact
coordinate-cube remark has not been given a separate literal endpoint here.
Do not identify these remaining ancillary statements with proved endpoints.

## Verification

`lake build NeuralGeneralization.BatchTwoContinuousFiniteMain` passed (3,414
jobs, including cached dependencies). The final `#print axioms` lists only
`propext`, `Classical.choice`, and `Quot.sound`. Build log:
`/tmp/batch-two-contfincomplete-build.log` in the working environment.
The strong-prior endpoint separately has the same standard three axioms.
Independent semantic review and the collection-wide build are separate checks.
