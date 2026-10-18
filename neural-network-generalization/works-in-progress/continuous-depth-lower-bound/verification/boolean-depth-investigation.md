# Boolean circuit / intrinsic-product bridge: fourth-round investigation

Research note, 18 October 2026. This is an investigation record, not a new theorem resolving the unrestricted-depth conjecture.

## Scope and outcome

I checked the latest unrestricted-depth paper, its depth-independent product-norm normal form, the excess-energy characterization, the circuit blocking argument, and the previous final-gap investigation. I did not find either a polynomial-product implementation of arbitrary small Boolean circuits or an explicit small Boolean circuit family with a superpolynomial intrinsic-product lower bound.

The distinction between implementation costs and function-level lower bounds remains essential. Exponential Frobenius product for a chosen circuit translation, serial machine, or branching program does not establish a sample-complexity lower bound for the original Bayesian learner.

## A precise complexity-theoretic obstruction to a Boolean counterexample

Let `f_d` be a Boolean family with polynomial-size bounded-fan-in circuits. Let the teacher width, teacher depth, and learner depth be polynomially bounded in `d`, with learner depth eventually at least every fixed constant. Fix a positive exponent gap `zeta` above one. The existing threshold-circuit simulation proves the following implication:

> If `f_d` belongs to nonuniform TC0, then the original unrestricted posterior at every actual width above its bounded-weight complexity and every variance parameter `sigma^2 <= N^(-(1+zeta))` has sample complexity polynomial in `d`, learner depth, inverse accuracy, and log confidence.

The polynomial can depend on the fixed TC0 depth and its fixed polynomial size exponent. Consequently, a superpolynomial-in-`d` sample lower bound for such a family would prove that the family is outside TC0. If the chosen target family is in NC1, this would separate NC1 from TC0. An intrinsic-product lower bound that is superpolynomial in `d` has the same consequence, directly from the fixed-depth threshold-to-tanh construction.

There are two qualifications:

1. An `exp(c h)` lower bound when `h = O(log d)` is only polynomial in `d`, so it does **not** establish the superpolynomial conclusion needed to refute a joint polynomial resource bound.
2. A lower bound for one fixed architecture that can be avoided by a larger, fixed-depth representation does not give a lower bound on the all-depth intrinsic product complexity. Nor does it defeat the existing all-width learning theorem, which already covers actual minimum-width learners using the separate finite-width branch.

This is not a proof that the conjecture is true. It identifies why the most natural explicit Boolean negative targets are difficult.

## Why a continuous oscillation lower bound does not automatically solve the Boolean problem

A one-dimensional deep network can produce rapidly oscillating real-valued behavior. Encoding a discrete grid coordinate by its binary digits may turn the resulting classifier into parity, modular counting, or bit extraction. These Boolean functions have small fixed-depth threshold circuits and hence polynomial intrinsic product norm under the existing simulation. Large oscillation count along a specially ordered one-dimensional list is not an invariant of the function on the Boolean cube.

Thus a continuous-domain obstruction can be valuable in its own right, but its transfer to the original Boolean model needs a separate function-level argument. The same warning applies to using communication rank or Fourier coefficient counts: fixed-depth threshold families already exhibit large values of several such measures.

## Composition routes checked

### Near-identity serial memory

Suppose a layer transports an `r`-dimensional linear memory with minimum singular value at least `a`. Its Frobenius norm is at least `a sqrt(r)`, because its squared Frobenius norm is the sum of squared singular values. A sequence of such layers therefore pays a product at least `a^T r^(T/2)` when the requirement holds uniformly over the same-dimensional memory subspaces. Scalar amplitude rescaling between layers cancels in the total product.

This explains the cost of ordinary serial simulation and constant-width branching-program implementations. It is only an obstruction to implementations that preserve that memory geometry at every stage. The final Boolean function may have a different low-product representation. Moreover, a finite-state encoding need not occupy a full linear ball, so this singular-value argument cannot be imposed on an arbitrary nonlinear finite-state representation without an extra hypothesis.

### Barrington-style simulation

An NC1 formula can be converted to a polynomial-length constant-width branching program, but this makes computation sequential. A direct finite-state network pays a nontrivial constant norm factor at each of polynomially many steps. Balanced aggregation of constant-size state transitions reduces depth, but blocking `b` transitions produces a truth table with size exponential in `b`; polynomial width permits only `b = O(log S)` children per aggregate, hence the familiar `log S / log log S` number of aggregation levels. This route does not give polynomial intrinsic product norm for NC1.

### Unequal neuron amplitudes and exact cloning

Optimizing layerwise amplitudes or clone multiplicities does not remove the balanced-tree obstruction: the factors introduced in one adjacent matrix telescope with the next. Nonuniform allocation can help asymmetric circuits, but a symmetric balanced tree still retains the Frobenius cost of simultaneously live branches. This repeats the known method obstruction rather than yielding a function-level lower bound.

### Circuit-history witnesses and tensor-style dynamic programming

Expressing a circuit output as existence of a consistent internal assignment gives a shallow construction with exponentially many history witnesses. Local averaging can keep intermediate maps contractive, but the probability of a complete consistent assignment can then be exponentially small; recovering unit output margin reintroduces a large final gain. A successful implementation would need to avoid this gain without storing all branches. No such construction was established.

## What remains a viable positive direction

The strongest current path to a universal positive theorem remains a representation or minimizer theorem that is genuinely stronger than direct circuit simulation. Examples of sufficient advances would be:

- every bounded-weight small circuit admits a functionally equivalent polynomial-product implementation;
- every minimum-energy globally margined interpolant with a small-circuit comparator has a polynomial-size Boolean description, even when the entire energy sublevel set does not;
- a posterior-specific complexity estimate that excludes the high-description part of an energy sublevel set without an imposed robustness restriction.

None is supplied by the arguments above. The first would also need attention to the learner-depth qualification in the current product-target sufficiency theorem. The present positive bounds remain polynomial for fixed-depth threshold targets and quasipolynomial for general polynomial-size logarithmic-depth bounded-fan-in circuits, with the published `S^{O(1+h/log log S)}` dependence for a size-`S`, depth-`h` circuit.
