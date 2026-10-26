# Shallow targets under deep logistic and softplus posteriors

**[Logistic paper](logistic.pdf)** · **[Softplus companion](softplus.pdf)** · [Verification](verification/README.md)

Research proof drafts by ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. These supporting results concern the standard logistic and softplus activations, augmented Boolean inputs, no internal biases, and a linear readout. The posterior conditions on absolute output margin greater than `1/2` at every cube input and then on exact training labels. Both-label samples are included.

- **Logistic:** every bounded-weight one-hidden-layer teacher has polynomial sufficient sample size in its resources, learner depth, and statistical parameters, at every eligible finite learner width. This holds for every strong-prior limiting sign posterior and for the actual finite-scale posterior at each fixed exponent `gamma > 1`.
- **Softplus:** the analogous shallow-target sample upper is quasipolynomial, once learner depth exceeds a constant times the squared logarithm of the teacher transmission resource. It holds in the same cold and fixed-`gamma > 1` regimes, at every eligible finite width. The companion states the depth qualification explicitly.

Here eligible width means `N >= C`, where `C` is teacher width. The finite-scale range is `t <= N^(-(gamma-1)/2)` for prior variances `t²/d`, `t²/N`, and `t²/N²`. Polynomial degrees may depend on the fixed gap `gamma-1`; no uniformity as this gap tends to zero is claimed. A fixed positive teacher margin is absorbed into its readout-weight bound.

The logistic construction uses complementary neurons to transmit the computed target with energy `16L + O(log T + 1)` once `L-1 >= log T`, matching the leading nonconstant energy lower bound; its exact bound also handles smaller depths. Softplus uses a positive signal channel and a charged constant channel, achieving energy `L + O(log²(LT))`. The proofs retain the actual Gaussian normalization: a robust witness, a Gaussian-distance posterior bound, and centered activation maps reduce the posterior to a common finite class. The logistic paper proves the needed width-independent Lipschitz cover and small-width fallback directly. The softplus companion uses those two general arguments and supplies its different transmission and stability proof.

Parity has polynomial-size shallow teachers for both activations, so it cannot produce an exponential-depth lower bound in these regimes. **The critical exponent `gamma = 1`, a fixed positive canonical prefactor, arbitrary deep teachers, and the original exact-tanh depth problem remain open.** These activation changes do not settle the original tanh question.

## Proof material

- [Logistic source](source/logistic.tex) and [derivation](research-notes/logistic-nonconstant-energy-and-cold-learning.md).
- [Softplus source](source/softplus.tex) and [derivation](research-notes/softplus-positive-channel-transmission.md).
- [Constant-target ordering note](research-notes/nonzero-offset-activation-ordering.md), with its [independent audit](verification/nonzero-offset-activation-posterior-audit.md): a separate actual-posterior one-example result for sufficiently deep logistic and softplus learners. Its constant-target normalization is not used for the both-label theorems.

The mathematical checks are conventional independent audits. **These results are not Lean verified.** The [build manifest](verification/build-manifest.json) records source provenance and exact packaged hashes.

## Build

Run `./build.sh` in this directory. It uses two `pdflatex` passes per manuscript, stores auxiliary files in `.build/`, and writes `logistic.pdf` and `softplus.pdf`.
