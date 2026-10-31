# Online learning of AND under Gaussian neural-network priors

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [verification](verification/README.md)

Does the exponential online-mistake example for deterministic circuit Occam learning also work for NNBayes? The answer depends on the prior, depth, and prediction rule. This note proves the following distinctions.

| Model | Result for arbitrary input orders |
|---|---|
| Original independent-Gaussian tanh prior, `gamma=0`, fixed depth | AND has polynomial total expected posterior-sampling mistakes at all sufficiently large widths. Majority and strict `>2/3` confidence also have polynomial bounds. The budget is `O(d^4 (pi/2)^(L-1))` at the stated fixed output margin. |
| Same prior, depth `L=O(d)` | At all sufficiently large finite widths, **every** ordering of the cube gives at least `(2/5) 2^d` expected sampled mistakes on AND. Every new point fails strict `>2/3` confidence. A high-probability sampled-error lower bound also holds. This does not imply a majority-error lower bound. |
| Strong prior with an arbitrarily small unequal perturbation of input-coordinate variances, one hidden neuron | A fixed input permutation forces at least `2^floor(d/8)` mistakes on AND. For odd `d`, the same construction works for majority, whose bounded-weight teacher complexity is exactly `C=1=N`. The lower bound covers sampling, majority, and confidence at sufficiently small positive common variance. This **changes the exact isotropic prior**. |
| Original equal-coordinate-variance strong prior, one hidden neuron | Odd majority has `C=1=N` and a fixed input order with **Omega(d^2)** expected sampled mistakes, a corresponding high-probability bound, and at least `(d-1)/2` majority mistakes at sufficiently small positive scale. See the [proof](source/majority-ood.tex). This is polynomial in dimension. |
| Original equal-coordinate-variance strong prior or `gamma>=1` | An exponential arbitrary-order counterexample is **not established** here. The one-neuron AND calculation explains why the circuit proof does not transfer; it is not a theorem for all later energy levels or all widths. |

All neural priors retain the all-input absolute output-margin restriction and exact noiseless conditioning. No function-rank flattening or alternative prediction rule is used. The anisotropic result changes only the specified Gaussian coordinate variances; its perturbation is fixed before the common variance is made small.

The growing-depth weak-prior example uses the unchanged Gaussian prior. Its kernel becomes sufficiently close to the identity that **full-margin function probabilities**, not just unconditioned outputs, are uniformly comparable. The finite-width threshold exists but is not quantified. The fixed-depth upper bound uses an affine mean shift realizing AND and a relative-entropy estimate of its function probability. Its finite-width threshold is likewise unquantified and not uniform as an extra common Gaussian scale tends to zero.

For the perturbed strong-prior construction, the initial lowest-energy functions are majority thresholds on selected supports. Tiny unequal variances split their exact ties without allowing any higher-energy function below them. Each queried counterexample eliminates only a small fraction of these supports; covering all of them takes exponentially many mistakes. The same one-neuron class has polynomial iid sample complexity under every prior on its functions, so this is an iid-versus-online separation. The AND version by itself does not meet the separate bounded-weight width convention at width one; the majority version does.

The original paper has conventional proofs and independent AI-agent reviews. The added majority note has been checked in this pass. These results are **not Lean formalized**. Run `bash build.sh` to rebuild the PDF. Generated `build/` files are not published.

The [31 October research continuation](verification/isotropic-ood-continuation.txt) records the remaining superpolynomial question and an exact fractional-energy certificate. This certificate rules out an integer-energy shortcut; it is not a mistake lower bound. Run `python3 verification/check_fractional_energy.py` to check it using only rational arithmetic.
