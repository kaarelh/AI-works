# Independent audit: logistic complementary rails and cold learning

25 October 2026. Audited `logistic-nonconstant-energy-and-cold-learning.md`,
the scalar-transmission lemma in
`works-in-progress/unrestricted-depth/source/unrestricted-background-productnorm.tex`,
and the universal zero-preserving Lipschitz extension in
`logarithmic-prefix-cover.md`.

**First verdict: PASS for Sections 1--5 and their strong-prior conclusion,
conditional on the explicitly imported product-cover theorem.** The
argument in those sections alone gives no finite-positive-scale comparison.
The separately added Sections 6--8 are audited below.

1. On a bichromatic cube edge the output difference exceeds one, the
normalized input distance is `2/sqrt(d)`, and each logistic hidden map is
`1/4`-Lipschitz. Thus the product lower bound and
`kappa >= 16L exp[(log d-log 64)/L]` have the stated constants. The elementary
`exp(u)>=1+u` gives the claimed linear baseline even when the correction
is negative.

2. For `M=2 floor(N/2)`, the two complementary groups satisfy
`a.h=tanh(z)` and `||a||^2=4/M`. The first added layer costs at most
`4D alpha^2`, each following layer costs `16b_j^2`, and the doubled final
readout costs at most `32c^2`. The scalar lemma, applied to coefficient
`D/4`, therefore gives exactly the stated
`E1+16(L+12) max(1,D/16)^(1/(L-1))` bound. The lemma includes the endpoint
`L=3` (its empty internal sum); the ignored odd-width neuron contributes
no weights or output despite its logistic activation being `1/2`.

3. Padding to `M0` and balanced cloning give `E1<=2` and
`D<=2M0 C B^2`. If `t=T^(1/(L-1))>=1`, then
`(K_L+1)/(16L) <= (1+13/L)t`. Raising to `L/2` gives the asserted
`4 exp(13/2) T^(3/4)` bound, since `L/[2(L-1)]<=3/4` for `L>=3`.

4. Anchor subtraction is exact, including the first layer when its input
is `(1,x)/sqrt(d)`. The rescaled scalar activation fixes zero and has
derivative bounded by one. Its product is
`4^(-(L-1)) product ||A_j||`, yielding formula (5). Nonconstant signs give
`|z(x0)|<=2P` without any bound on the internal anchor offsets. The
universal Lipschitz cover permits distinct neuron activations and finite
lookup tables, so the activation shifts create no precision assumption.
For the affine-shifted input one can simply retain all `d` coordinates,
use its radius-two bound, and count descriptions polynomial in `d+P`;
no shifted-input junta argument is needed. The original half-margin is
handled by doubling the output, which changes the polynomial bound only
by a constant factor. A scalar offset bounded by `2P` can be quantized to
a fixed margin-safe mesh.

5. At each fixed finite architecture, a ball around the strict-margin
witness belongs to the denominator for every target-labeled sample. Its
energy can be kept below `K+eta/2`. The Gaussian radial tail above
`K+eta` divided by that ball mass vanishes exponentially in `1/sigma^2`;
polynomial factors in `sigma^-1` are harmless. This proves the stated
cold energy concentration uniformly over samples at that architecture,
without discarding either conditioning event. Any limiting sign
posterior is sample-consistent and supported on the common finite
low-product class. Standard finite-class consistency followed by the
Gibbs-to-confidence inequality gives the claimed polynomial sample
bound. Using slack in the error constants also covers the convention
that confidence exactly `2/3` counts as failure.

6. For `C<=N<M0`, the dimension is polynomial in teacher resources and
`L`; the same paired witness has polynomial energy. A finite-dimensional
energy net suffices and does not require importing a tanh-specific
counting theorem for logistic. For `N=1`, every final hidden coordinate
is strictly positive, so the classifier is constant and one label fixes
its truth table. These cases cover the widths not covered by cloning.

The distinction between a cold limit at each fixed finite architecture
and a bound uniform in a prescribed positive prefactor is essential and
is retained correctly in the source note.

## Separate audit of added Sections 6--8

**Verdict: PASS for the fixed-exponent `gamma>1` extension**, using the
same explicitly imported universal Lipschitz cover and the stated standard
Gaussian operator set/isoperimetry. This does not prove the critical
`gamma=1` case or a uniform fixed-prefactor statement.

For the planted wire, every consecutive internal gain product telescopes
the `k` ratios, contributes at most `q^m=sqrt(T)`, and accumulates only
the constant factor `exp(sum r_s^2/2)`. The first added logistic gain is
at most `Cq` because `D<=D0` and `D'=max(D0/4,4)`; the readout norm is
at most `4sqrt(2)q`. All required suffix products are therefore bounded
by `CLT`. Perturbation errors at each normalized hidden state are at
most `eta/4`, since even perturbed logistic states have norm at most
one. The first input has norm at most `sqrt(2)` and causes only the
stated constant adjustment. Summing the suffix contributions gives
`CL^2 T eta`, with no assumption that perturbed complementary pairs
remain complementary. The first teacher layer itself has normalized
operator norm at most `sqrt(2)` after cloning. The shallow `L=2`
endpoint follows directly from `D0=O(T)`.

For a centrally symmetric Gaussian set of probability at least one half,
the shift mass lower bound follows by pairing opposite points and using
`cosh>=1`. Isoperimetry gives raw tail at most
`exp[-(K_L+1)/(2sigma^2)]`; dividing by the target shift mass gives
exactly `2exp[-1/(2sigma^2)]`. The target shift belongs to every relevant
sample conditioning event, so this is an actual posterior ratio.

The realized centered activation functions are fixed scalar maps when
the subtraction is performed. Replacing only their linear matrices by
`U=A-proj_T(A)` gives a legitimate auxiliary zero-preserving Lipschitz
network. It need not be realizable by a common logistic bias choice.
Since that enlarged class is exactly the one covered by the imported
capacity theorem, this is not a circular use of an unproved logistic
representation theorem.

To check (12), divide every block, including the readout, by four and
place a factor four outside. In each telescoping summand, a single
operator perturbation costs `eta`; the product of the remaining `L-1`
norms is at most
`[(sqrt(Knorm)+sqrt(L)eta)^2/(L-1)]^((L-1)/2)` by Cauchy--Schwarz and
AM--GM. The radius-two input and factor-four output give the coefficient
`8L eta`. Under `tb<=c/(L^2 T)`, the perturbation changes the numerator
energy by at most an absolute constant. Since
`Knorm<=(L+13)T^(1/(L-1))`, the power is at most `C sqrt(T)`. The
bound is below `1/8` for a sufficiently small absolute `c`, uniformly
in `L>=3`; `L=2` has the same estimate from its direct energy bound.
Hence the surrogate preserves all signs and has margin greater than
`3/8`. Its anchor output equals the actual retained offset because its
centered input at the anchor is zero. If its signs are nonconstant,
the radius-two Lipschitz argument bounds that offset by twice its
product. Thus the common finite class is independent of the sample,
width, depth, and realized shifts.

For fixed `zeta>0`, `t<=N^(-zeta/2)` makes the operator-smallness
condition hold above a polynomial threshold whose degree depends only
on `zeta`. Widths below that threshold can be handled at positive scale
by the same elementary net argument as the finite-width posterior
paper: bounded normalized logistic states give
`log Lip_R=O(L log(2+R+L))`; a margin-stable witness ball and a Gaussian
energy tail give a polynomial energy radius and a net of polynomial
log-cardinality in `N,d,L,C,B,log(1/beta)`. The ball side is capped at
the Gaussian standard deviation, so no `log(1/t)` divergence is
introduced. Here `N` itself is polynomial in the displayed resources.
This closes the small-width branch at every positive variance in the
fixed-exponent regime, and the large-width branch uses the actual
posterior subtraction above.
