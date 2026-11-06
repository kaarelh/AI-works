# Subexponential online bounds for narrow isotropic tanh learners

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification](verification/README.md)

These results rule out `exp(Ω(d))` mistakes in specified narrow architectures under the unchanged isotropic Gaussian strong prior. They retain the all-input absolute margin and exact label conditioning, and apply to every input order, including adaptive orders chosen before the current private prediction.

| Learner and target | Cumulative posterior error bound |
|---|---|
| One neuron at every hidden layer, any fixed depth; target affine unit-margin cost `Q(f)≤K` | `exp(O(K^(1/3) log(K+1))) [1+K log(d+2)]` |
| Same scalar learner; target admits a width-one implementation with every weight at most one | `exp(O(d^(1/3) log(d+2)))` |
| Same scalar learner; target is AND of all `d` bits | `exp(O(d^(2/3) log(d+2)))` |
| One hidden layer, any **fixed** learner width `n`; target has depth-two bounded-weight complexity `C₂=1` | `exp(O_n(d^(n/(n+2)) log⁴(d+2)))` |

The bounds control expected sampled mistakes, posterior-majority mistakes, strict `>2/3` confidence failures, and high-probability sampled mistakes. They also hold, with an additive one, at every sufficiently small positive scale. The scale threshold may depend on the dimension, architecture and target.

The proof partitions low-energy functions into exact symmetry orbits. Gaussian probabilities are exactly equal within each orbit, even when different orbits have very unequal probabilities. Each orbit contributes at most one plus the logarithm of its size to total posterior error. Coefficient separation bounds the scalar orbit count. For wider shallow networks, nearby input columns imply exact Boolean symmetries; higher moments of permutation-averaged outputs then give a short description of each orbit.

These are **subexponential upper bounds, not polynomial bounds**. The fixed-width constants do not give a width-uniform theorem. The wider-network result requires one hidden layer and a `C₂=1` target; the AND bound concerns the scalar architecture. General widths, deeper wider networks, and possible superpolynomial mistakes below these upper bounds remain unresolved here.

The [companion counterexample](../isotropic-exponential/) proves exponential mistakes for a different target with a linear-depth, weight-two scalar implementation. Its affine margin cost is exponential, so it is consistent with these bounds.

Conventional proofs with independent AI-agent reviews; **not Lean formalized**. Run `bash build.sh` to rebuild the PDF.
