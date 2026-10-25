# Arithmetic formulas for low-product tanh networks

**[Read the paper](paper.pdf)** · [Main LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

By ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. Research draft, 25 October 2026.

This paper proves that a Boolean function with a globally unit-margin tanh representation of Frobenius product `P` has a logarithmic-depth integer arithmetic circuit of size polynomial in `d + P` whose output sign equals the function. The original network may have arbitrary finite depth, widths, and real weights. Consequently, polynomial-product families belong to **nonuniform PNC¹, and hence L/poly**. This is an arithmetic-sign result; it does not establish Boolean NC¹.

The proof uses an exact Fourier–Poisson estimator for tanh whose expected arithmetic work times second moment grows by only a universal constant. Cost-aware neuron sampling gives a Frobenius-norm recurrence. The paper includes the ordinary-tanh short-depth normal form, width compression, finite-bit rounding, and formula balancing needed to complete the argument.

It also proves a Bayesian converse using an explicitly stated existing posterior ceiling. For the original Gaussian tanh learner with exact training labels and an absolute margin greater than `1/2` on the entire Boolean cube, a distribution-free sample guarantee with confidence-failure mass at most any `ε < 1/2` forces a small arithmetic-sign circuit for the target. This applies to every fixed **γ > 1** at sufficiently large finite width, and to the **strong-prior limit** at the stated fixed widths. The two majority reductions handle full posterior mixtures and the requirement that the correct label receive probability greater than `2/3`.

A universal polynomial sample bound for unrestricted bounded-weight deep teachers in either of these regimes would therefore imply **P/poly = nonuniform PNC¹ = L/poly**. This is a conditional complexity consequence, not an established contradiction or an exponential-depth sample lower bound. The general unrestricted-depth learning question remains open. The strengthened converse does not cover **γ = 1**: the low-action expectation maps arising there have not been shown to admit the deterministic low-product tanh representations required here.

The [online converse note](research-notes/online-depth-independent-circuit-converse.md) gives a related conclusion: a bound of `M` on expected total confidence errors or Gibbs mistakes **for every iid input distribution** forces a circuit of size polynomial in `d + M`, independently of learner depth. It uses the same sufficiently-large-width or strong-prior hypotheses, and does not cover ordinary majority mistakes or a guarantee for just one input distribution. The note has a [separate independent audit](verification/online-depth-independent-circuit-converse-audit.md).

## Contents and dependencies

- [Paper](paper.pdf): the representation proof is self-contained apart from standard probability, finite minimax, and the cited arithmetic-complexity theorems.
- [Width-compression proof](source/width-compression.tex) and [short ordinary-tanh normal form](source/normal-form.tex): included appendices, not additional reading prerequisites.
- [Bayesian consequence](source/posterior.tex): states the imported Gaussian posterior theorem with explicit constants and proves the new consequence in full.
- [Exact dependency manifest](DEPENDENCIES.json): identifies the existing [posterior ceiling source](../unrestricted-depth/source/unrestricted-primary-posterior-ceiling.tex) and its supporting Gaussian construction.
- [Verification record](verification/README.md): mathematical reviews and build checks. **These new statements and proofs are not Lean verified.**

## Build

From this directory run `./build.sh`. It requires `pdflatex` and the standard LaTeX packages listed in the source. Generated auxiliary files go in `.build/`; the finished document is copied to `paper.pdf`.
