# Independent audit of the Fourier–Poisson tanh representation

25 October 2026. Conventional mathematical audit, not Lean verification.

Audited sources:

- `fourier-poisson-tanh-formulas.md`, Sections 1–4;
- `fourier-poisson-finite-bit-completion.md`, Sections 1–7;
- the ordinary-tanh logarithmic-depth normal form in
  `logarithmic-prefix-cover.md`, starting at its second theorem.

The analytic estimator, cost-aware recurrence, finite-cube derandomization,
and finite-bit construction pass this audit. The resulting conclusion is a
nonuniform arithmetic-sign complexity upper bound, not Boolean NC1 and not
a resolution of the original unrestricted-depth Bayesian learning problem.
The final named-class conclusion additionally uses the explicitly cited
arithmetic-complexity closure/evaluation theorems.

## Scalar estimator

The Fourier identity has the correct normalization: the derivative integral
`integral omega/sinh(pi omega/2) d omega` equals one. The Poisson product has
mean `exp(i omega mu)` and second moment
`exp(omega^2 E[X^2]/lambda)`, with `lambda=1+omega^2 V`.
These statements require only the stated second moment, because the number
of independent child expressions is Poisson and its generating function is
finite at every fixed finite argument.

Writing `a=omega^2 E[X^2]/lambda` and `b=omega mu`, the useful small-frequency
bound follows from

    E|Z-1|^2 = exp(a)-1 + 2(1-cos b)
             <= (e-1)a + b^2 <= C omega^2 V.

Together with `E|Z|^2<=e`, this gives the required minimum of one and
`omega^2 V`. In particular the importance-sampled integrand is absolutely
integrable, so unbiasedness does not rest on a conditionally convergent
exchange of integrals. The inequalities for A(V) are immediate from
`r <= min(1,r)sqrt(1+r^2) <= sqrt(2)r`. Multiplying the work and second-moment
bounds cancels Z(V), leaving a universal constant times VT.

Work here counts arithmetic leaves and gates in a nonuniform expression.
It does not claim an efficient exact algorithm for sampling real frequencies
or computing the real importance constants. The finite-bit step is what
turns a selected expression into a finite mathematical representation.

## Linear sampling and layer potential

The cost-aware probabilities give second moment at most LM and expected
child work M/L. Since every child work bound is at least one, M/L>=1 and
the fixed arithmetic overhead can be absorbed. The sampled child is the
only child called at this linear gate; no covariance terms are missing.
Fresh independent copies are used at the subsequent Poisson products.

Applying Cauchy–Schwarz to each row and then summing gives

    sum_i K_i <= C ||W||_F^2 sum_j K_j.

Thus a depth-h representation has potential at most
`C^(h+1)(d+1)P^2`. The use of logarithmic depth later is essential: this
calculation alone has an exponential factor in the depth.

## Finite-cube selection

For unit-margin scalar outputs, V>=1. A group of ceil(40V) estimators has
pointwise error at most one half with probability at least 0.9. Independent
groups, Chernoff, and a union bound over the cube give a strict two-thirds
majority of good groups at every input using O(d+1) groups. Combining this
event with a Markov size bound leaves positive probability. These are joint
events in the original unbiased sampling construction; conditioning on a
frequency cutoff is not used to claim that the estimator remains unbiased.

The expected-number-of-nodes union bound for bad frequencies is valid even
though the random tree size depends on earlier frequencies. For each tree
address, the event that this node is reached is determined before its fresh
frequency is sampled. Summing the conditional bad-frequency probabilities
over addresses therefore costs only the expected number of reached nodes.

## A precision issue in the initial scaffold, and its repair

The initial Section 5 scaffold bounded all normalized activation scales from
the output margin. That bound cannot be transferred without explanation to
an arbitrary neuronwise-normalized Maurey representation: a negligible
neuron can have an arbitrarily large scale. This is not a defect in the
estimator or its potential estimate.

The finite-bit completion avoids the issue entirely by first invoking the
proved **ordinary-tanh** normal form: logarithmic hidden depth, polynomial
physical width, polynomial product and physical weights, and polynomial
dyadic precision. It then applies the scalar estimator directly to these
ordinary tanh neurons. No unproved bound on neuron-specific scales remains.
The normal form's prefix constant rail, finite-cover classifier, and final
physical-weight normalization are necessary dependencies of this route.

## Internal constants, rounding, and denominators

The elementary estimate

    Z(V) is within universal constant factors of min(sqrt V,1)

is valid in both regimes. For V<=1, integration over [1,2] supplies a lower
bound, including when `omega sqrt V` crosses one. For V>=1, the interval
[0,1/sqrt V] supplies a constant lower bound; splitting the upper integral
there and using `k(omega)<=C/omega` below one and exponential decay above one
supplies the constant upper bound. Hence logarithmic bounds for V,T grow by
only a universal factor per layer. At logarithmic depth all logarithmic
magnitudes remain polynomial in d+P.

The chosen finite-frequency interval therefore has endpoints with polynomial
logarithmic magnitude and can be imposed jointly with correctness and size
with positive probability. The formulas for `w/p`, `omega/lambda`, and `k/q`
then bound every realized constant by `exp(poly(d+P))` in modulus. Only upper
bounds on the final realized constants are needed for rounding.

A formula of polynomial size with constants of these magnitudes has
coefficient sensitivity at most `exp(poly(d+P))` on Boolean inputs. This can
be seen by expanding with each constant occurrence treated independently, or
by a direct gate induction. Real/imaginary-part gates are real-linear and do
not invalidate the bound. Polynomial-bit dyadic rounding therefore perturbs
each group output by less than one eighth. At every input more than half
the groups retain margin at least three eighths, so their majority is still
correct even if every other group's sign changes.

Positive denominator clearing has polynomial size: at an addition the two
child numerators each occur once, and the child denominators are precomputed
integer constants. Their bit lengths add over the subtree. Real and
imaginary parts commute with division by these positive real denominators.

## Balancing complex formulas

Direct recursive expansion of complex multiplication can duplicate an
unbalanced formula exponentially; the completion correctly balances first.
For a single-occurrence subtree Q, its context is real-affine, even with
real/imaginary-part gates. Thus

    F = (F[Q:=1]-F[Q:=0]) Re Q
      + (F[Q:=i]-F[Q:=0]) Im Q + F[Q:=0].

A centroid-size subtree and its three substituted contexts have size at most
a fixed fraction of the original, up to constant additive terms. Recursively
balancing them introduces only a constant number of copies per recursion
level, so total size remains polynomial and depth becomes logarithmic.
Only then expanding complex gates into pairs of real integer formulas costs
another polynomial factor. This resolves the otherwise substantive formula
versus circuit issue.

Polynomial-bit integer constants can be built from -1,0,1 using balanced
products of twos and balanced sums of powers of two. This increases size by
a polynomial and adds only logarithmic depth. Sign inputs can be converted
from bit inputs by the affine map `2b-1`, with constant overhead.

## Named complexity classes and limits

The construction supplies polynomial-size logarithmic-depth integer
arithmetic circuits whose signs compute the group predicates, followed by
a majority of polynomially many such signs. Majority itself belongs to
PNC1. Interpreting it as a top PNC1 oracle gives a constant number of oracle
composition levels, so the cited `AC0(PNC1)=PNC1` theorem is the relevant
closure statement. The cited `PNC1 subset L` inclusion then yields L/poly
with the existential formulas and constants supplied as polynomial advice.
No conclusion that these signs have Boolean NC1 formulas follows from
arithmetic formula balancing.

I independently checked the [primary Datta–Mahajan–Raghavendra Rao–Thomas–
Vollmer paper](https://www.cse.iitm.ac.in/~bvrr/conf/mfcs10.pdf): its arithmetic
gate conventions match these formulas; Proposition 2.4 gives the logspace
inclusion, Theorem 4.1 gives the constant-depth closure, and Theorem 4.2
explicitly handles two adjacent PNC1 oracle levels. Proposition 3.4 also
applies directly to the two nested positivity-test levels of this
construction. Advice is necessary here because the selected formulas are
nonuniform; no uniformity of their coefficients has been proved.

This is a representation theorem for low-product deterministic ordinary tanh
networks. It does not establish that every small deep Boolean circuit has a
low-product implementation. Nor does it automatically improve a mean-field
Bayesian converse, where low-action descriptions may be expectation maps
rather than deterministic tanh networks. Those transfers require separate
proofs. The current argument has not been formalized in Lean.
