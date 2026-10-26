# Depth dependence, parallel circuits, and Boolean learning

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Uniform-scale companion](uniform-target-classes.pdf) · [Proof dependencies](DEPENDENCIES.json) · [Lean components](lean/README.md)

**The unrestricted Boolean-depth learning question remains open.** This paper gives structural theorems and conditional complexity barriers for the original Gaussian tanh posterior. It does not establish either a general polynomial-depth sample bound or an unconditional exponential-depth sample lower bound.

The main conclusions are:

- A globally unit-margin Boolean network with Frobenius product $P$ has a threshold circuit of size polynomial in $d+P$ and logarithmic depth. The neural network may have arbitrary finite depth and width, and arbitrary neuronwise zero-preserving 1-Lipschitz activations.
- For the original tanh prior, with variances $t^2/d,t^2/N,t^2/N^2$, **most posterior mass lies on functions having small parallel circuits**. More precisely, put $R=d+n+L+2$. At depths $L\ge C\log R$ and finite widths $N\ge2^{Cd}R^C+CL\log(1/\beta)$, every consistent sample of at most $n$ points leaves posterior mass at least $1-\beta$ on functions with circuit size polynomial in $R$ and threshold depth $O(\log R)$. The circuit class is common to all samples and all $0<t\le1$; this does not identify the posterior mixture with one circuit.
- A universal sample bound polynomial jointly in teacher width, depth, input dimension, and the statistical parameters, independent of learner width, would imply **P/poly = nonuniform TC¹**. The stronger assumption **P/poly = nonuniform TC⁰** suffices for such a bound.
- Even a fixed stretched-exponential sample lower bound in depth, with input dimension, teacher width, and the logarithm of the coefficient bound polynomial in depth, would separate **P/poly from nonuniform NC**. Exponentially large teacher coefficients are allowed when their logarithms are polynomial in depth. More quantitatively, a lower bound `exp(c L^alpha)`, for `0<alpha<=1`, would require threshold depth at least `Omega(L^alpha/log L)` at every fixed polynomial width. These are conditional consequences of such a sample lower bound, not proofs that it exists.
- A self-contained appendix implements every small Boolean circuit using width 24, coefficients bounded by one, and polynomial tanh depth. Thus the necessary collapse already follows for fixed-width teachers, while the learning guarantee must still cover arbitrarily large learner widths. The implementation uses delicate analog memory and has no polynomial-product or robustness guarantee.

A [supporting note](proof-notes/padded-resource-depth-barriers.md) extends the conditional barrier beyond polynomial resources. Put `R=d+C+L+log(2+B)+4`. An exponential-in-depth sample lower bound with `R=exp(o(L))` would separate P/poly from nonuniform TC⁰; if `log R=L^{o(1)}`, it would separate P/poly from nonuniform NC. This pads only the family used in the complexity argument, leaving the original learner and prior unchanged.

The hypotheses matter. The input distribution is arbitrary but common to training and testing; the network is conditioned to have absolute output margin greater than $1/2$ at every Boolean input; training labels are noiseless and fit exactly. The converse treats posterior mixtures. The all-width guarantee means a guarantee at each admissible width, not an unstated simultaneous event over infinitely many widths.

## Reading and proof dependencies

Start with the paper's introduction and Appendix B. Its new geometric, canonical-feature, finite-event, circuit-reduction, and constant-width-compiler proofs are included. The statistical applications additionally use the following explicit inputs.

| Input | Source |
|---|---|
| All-scale structured-target learning | [Companion PDF](uniform-target-classes.pdf), [source](source/uniform-target-classes.tex) |
| Uniform target-mass construction | [Critical-program reuse](proof-notes/nearcritical-target-reuse.md) |
| Scale-normalized intrinsic learning | [Basic intrinsic bound](proof-notes/uniform-scale-intrinsic.md), [baseline-subtracted bound](proof-notes/uniform-sharp-intrinsic.md) |
| Population compression and finite-event extraction | [Compression proof](proof-notes/fixed-t-compression.md), [bounded-dual certificate](proof-notes/finite-width-dual-certificate.md) |
| Uniform scalar gain estimate | [Baseline gain proof](proof-notes/uniform-baseline-gain.md) |
| Critical scalar and finite-width inputs | [Critical-depth paper](../critical-depth/paper.pdf), [modular sources](../critical-depth/source/) |
| Earlier above-one posterior ceiling | [Exact source](../unrestricted-depth/source/unrestricted-primary-posterior-ceiling.tex) |
| Polynomial-bit coefficient and quantitative-depth sharpening | [Supporting proof](proof-notes/polynomial-bit-weight-depth-barrier.md), [independent audit](verification/polynomial-bit-weight-depth-barrier-independent-audit.md) |
| Conditional barriers with subexponential teacher resources | [Complexity-only padding proof](proof-notes/padded-resource-depth-barriers.md), [independent audit](verification/padded-resource-depth-barriers-independent-audit.md) |
| Earlier threshold-target bounds | [Above-one source](../unrestricted-depth/source/unrestricted-primary-threshold-circuits.tex), [critical source](../critical-depth/source/critical-all-width-target-learning.tex) |
| Fixed-depth cloning cylinder | [Mean-field cloning proof](../../main-results/meanfield-all-width/source/cloning.tex) |

The six supporting proof notes supply the additional scale-uniform arguments. They are not substitutes for the older critical-depth inputs identified in the table. [DEPENDENCIES.json](DEPENDENCIES.json) records precise source files and hashes; Appendix B identifies the theorem labels and the role of each input.

## Verification scope

The paper has undergone independent mathematical audits, including a fresh audit of the actual-posterior quantifiers and the nearcritical block-cover argument. See the [verification record](verification/README.md). These audits are not formal verification.

The [Lean package](lean/README.md) checks the finite-dimensional Frobenius cover, finite-sample concentration and Maurey compression, an actual polynomial-size analytic prefix and prototype decoder, and the relevant-coordinate reduction. It uses no `sorry` or custom axioms. **It does not formalize the finite-bit TC¹ circuit compiler, the posterior results, the target-mass inputs, the constant-width compiler, or the circuit-class implications.** This paper therefore remains a work in progress rather than a fully formalized main result.

## Reproduction

Run `./build.sh` with a standard TeX installation including `latexmk` to rebuild both PDFs. Lean installation and build instructions are in [lean/README.md](lean/README.md). Build artifacts are excluded from version control.
