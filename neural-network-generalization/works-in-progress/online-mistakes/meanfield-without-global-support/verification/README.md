# Verification record

The theorem and proof received independent mathematical reviews from three other AI agents. This is **not Lean verification**. The proof invokes the standard finite-dimensional Cramér large-deviation theorem; the remaining model-specific steps are proved in the paper.

The reviews checked:

- Exact model and quantifiers: shallow tanh; independent canonical mean-field Gaussian weights; fixed positive prior prefactor; training margins only; no initial global output condition; all sufficiently large widths, uniformly over input orders.
- Full feature span on the finite Boolean cube and everywhere-finite cumulant, including its quadratic lower bound. These give a smooth strictly convex coercive rate function and finite exponential tilts for every output vector.
- Actual conditional posterior concentration. Mixing with a strict teacher establishes equality of open and closed rate infima, and uniqueness gives the conditional large-deviation gap.
- The exact entropy projection identity, the convex first-order inequality, the Gaussian second-moment bound, the unnormalized Hellinger inequality, and the constant `16` in the per-mistake payment.
- The explicit Gaussian-mixture teacher certificate, including its strict margin, no additional `log C` mixture penalty, and the fixed-`B, τ` polynomial `O(d⁴ + C⁴)`.
- The finite-history argument giving one width threshold for all input orders, and the expected and high-probability fresh-posterior-sampling conclusions for adaptive orders.

The separate geometry review records both the initial mathematical audit and the final LaTeX correspondence check. The published statement preserves the distinctions between this learner and a prior initially restricted by full-cube margins, and between the joint mean-field scaling `σ_N = τ/√N` and a fixed-width cold limit.

## Build and presentation checks

The supplied build script ran three `pdflatex` passes successfully on 6 November 2026. A separate isolated rebuild from the LaTeX source alone also passed; its extracted text is byte-for-byte identical to the published PDF's extracted text. Both final logs have no undefined references, overfull boxes, or LaTeX warnings. Pages 1, 2, 4, and 6 were rendered and inspected for the title, alphabetical authors and footnote, main statements, proof formulas, and scope qualifications. See the [machine-readable build record](publication-build.json) and [isolated-build summary](isolated-build.txt).

Published snapshot:

| File | SHA-256 |
| --- | --- |
| `source/paper.tex` | `5c707e6a545f287cb0739e6b0dc5dfb9ba6d74c02639ff7ebfcd45bbecb8fc91` |
| `paper.pdf` | `7b7bb942087705c6c93e8078c20980bd8ca89b33b3ef85f2b81dee1b6a81ca27` |
| `build.sh` | `b905b9f4f4e261c91b359c6d66e5dd9b0fbfaa98ff186d4e23b8d502af8d8377` |

The build directory is generated locally and need not be committed. Rebuilding can change PDF metadata and therefore its checksum without changing the mathematical source.
