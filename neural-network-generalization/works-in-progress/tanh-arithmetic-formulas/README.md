# Arithmetic formulas for low-product tanh networks

**[Read the paper](paper.pdf)** · [Main LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

By ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. Research draft, 25 October 2026.

This paper proves that a Boolean function with a globally unit-margin tanh representation of Frobenius product `P` has a logarithmic-depth integer arithmetic circuit of size polynomial in `d + P` whose output sign equals the function. The original network may have arbitrary finite depth, widths, and real weights. Consequently, polynomial-product families belong to **nonuniform PNC¹, and hence L/poly**. This is an arithmetic-sign result; it does not establish Boolean NC¹.

The proof uses an exact Fourier–Poisson estimator for tanh whose expected arithmetic work times second moment grows by only a universal constant. Cost-aware neuron sampling gives a Frobenius-norm recurrence. The paper includes the ordinary-tanh short-depth normal form, width compression, finite-bit rounding, and formula balancing needed to complete the argument.

An included [Fourier-increment appendix](source/fourier-activations.tex) extends the structural theorem to a class containing **normalized erf, arctan, and softsign**. It retains a short prefix with the original activation and uses tanh in a replacement suffix. A deterministic frequency approximation proves finite-bit control using only one weighted Fourier moment. The extension has a [separate assembled audit](verification/fourier-increment-low-product-compiler-independent-audit.md); the posterior claims below remain specifically about tanh.

It also proves a Bayesian converse using an explicitly stated existing posterior ceiling. For the original Gaussian tanh learner with exact training labels and an absolute margin greater than `1/2` on the entire Boolean cube, a distribution-free sample guarantee with confidence-failure mass at most any `ε < 1/2` forces a small arithmetic-sign circuit for the target. This applies to every fixed **γ > 1** at sufficiently large finite width, and to the **strong-prior limit** at the stated fixed widths. The two majority reductions handle full posterior mixtures and the requirement that the correct label receive probability greater than `2/3`.

A universal polynomial sample bound for unrestricted bounded-weight deep teachers in either of these regimes would therefore imply **P/poly = nonuniform PNC¹ = L/poly**. This is a conditional complexity consequence, not an established contradiction or an exponential-depth sample lower bound. The general unrestricted-depth learning question remains open. The strengthened converse does not cover **γ = 1**: the low-action expectation maps arising there have not been shown to admit the deterministic low-product tanh representations required here.

The [online converse note](research-notes/online-depth-independent-circuit-converse.md) gives a related conclusion: a bound of `M` on expected total confidence errors or Gibbs mistakes **for every iid input distribution** forces a circuit of size polynomial in `d + M`, independently of learner depth. It uses the same sufficiently-large-width or strong-prior hypotheses, and does not cover ordinary majority mistakes or a guarantee for just one input distribution. The note has a [separate independent audit](verification/online-depth-independent-circuit-converse-audit.md).

## Companion: Gaussian-controlled feature paths

**[Read the Gaussian-controls companion](gaussian-controls.pdf)** · [Source](source/gaussian-controls.tex) · [Proof-note guide](research-notes/gaussian-controls-guide.md)

For a globally margined Boolean classifier represented by Gaussian-controlled tanh feature layers, this companion gives rational arithmetic formulas and **nonuniform PNC¹, hence L/poly**, with resources polynomial in `(d + H + ||v|| + 2) exp(C Σ_j(√D_j + D_j))`, where `D_j` is the Gaussian relative entropy of layer `j`. Controls may have arbitrary means and covariances, input-dependent variances, and unrestricted real precision. The proof supplies scalar formulas and finite-bit constants without assuming bounded precision of the original controls.

The **Gaussian scalar baseline `V_*^G` is strictly larger than the unrestricted baseline `V_*`**. A bounded-cost Gaussian scalar path must cross a fixed variance range, where replacing one Gaussian law by the entropy-optimal non-Gaussian tilt saves a uniform positive amount. Thus the Gaussian class at action `V_* + o(1)` is eventually empty as depth grows. The companion instead proves its useful near-baseline result relative to `V_*^G`, with resource exponent `O(log H + √(Hε) + ε)` at action at most `V_*^G + ε`. This class is nonempty on the prescribed augmented Boolean input: every fixed target approaches `V_*^G`, and constants and dictators do so with `O(log²(d+H)/H)` excess action.

This is a theorem about a restricted variational control class. A Gaussian weight prior does not make conditioned row laws Gaussian. The strict baseline gap prevents a Gaussian replacement from preserving vanishing excess above `V_*`; **the companion does not prove a converse for the original γ = 1 posterior or settle the unrestricted-depth learning question**. Its [occupation and scope audit](verification/gaussian-control-manuscript-occupation-audit.md), [finite-bit and assembled-path audit](verification/noncentral-gaussian-and-manuscript-finite-n-audit.md), and [build/dependency record](verification/gaussian-controls-build.json) are conventional checks, not Lean formalizations.

The [non-Gaussian controls companion](non-gaussian-controls.pdf) ([source](source/non-gaussian-controls.tex), [verification](verification/non-gaussian-controls/README.md)) extends arithmetic-formula compression to controlled tanh feature paths. Its layers may use arbitrary Gaussian changes, independent non-Gaussian blocks of any fixed rank, quadratic tanh density changes with bounded entrywise coefficient norm, or small quadratic tilts in normalized ridge differences. The last case permits diverging raw coefficients as anchor vectors approach one another. A logarithmic variance/entropy budget again gives PNC¹. For normalized ridge tilts, the represented coefficient mass must be uniformly small at each layer; it is not summed in the budget. A global covariance polar decomposition charges these layers by their actual entropy. The proof includes a positive Poisson mixture and finite-bit control of heavy-tailed scalar tilts. The first and last layers may additionally have arbitrary finite-entropy row laws: direct first-layer formulas and a truncated-density readout give an explicit endpoint overhead, constant at bounded action and fixed margin. **This does not extend the posterior converse to arbitrary internal critical row laws:** general conditional tilts and the required bounds on earlier variational costates remain open. Build this 16-page companion with `./build-non-gaussian-controls.sh`.

## Contents and dependencies

- [Paper](paper.pdf): the representation proof is self-contained apart from standard probability, finite minimax, and the cited arithmetic-complexity theorems.
- [Width-compression proof](source/width-compression.tex) and [short ordinary-tanh normal form](source/normal-form.tex): included appendices, not additional reading prerequisites.
- [Bayesian consequence](source/posterior.tex): states the imported Gaussian posterior theorem with explicit constants and proves the new consequence in full.
- [Exact dependency manifest](DEPENDENCIES.json): identifies the existing [posterior ceiling source](../unrestricted-depth/source/unrestricted-primary-posterior-ceiling.tex) and its supporting Gaussian construction.
- [Verification record](verification/README.md): mathematical reviews and build checks. **These new statements and proofs are not Lean verified.**

## Build

From this directory run `./build.sh`. It requires `pdflatex` and the standard LaTeX packages listed in the source. Generated auxiliary files go in `.build/`; the finished document is copied to `paper.pdf`.

Run `./build-gaussian-controls.sh` to build the separate companion. Its auxiliary files go in `.build/gaussian-controls/`, and the finished document is copied to `gaussian-controls.pdf`.
