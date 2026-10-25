# Scalar arithmetic formulas for near-copy tanh trajectories

25 October 2026. Fresh research note. This proves a restricted deterministic
scalar-formula theorem. It repairs the sharing obstruction in the existing
residual-DAG argument when the linear maps are close in Hilbert--Schmidt norm
to coordinate-copy maps. It does **not** prove the critical posterior's PNC1
ceiling, an NC1-to-polynomial-product theorem, or a new learning bound.
No public repository file was changed. No Lean verification is claimed.

## 1. Statement

Let a finite input set X be given. Consider a finite-dimensional trajectory

    h_j(x) = phi_(s_j)(A_j h_(j-1)(x)),
    phi_s(t) = tanh(s t)/s,

with phi_0 the identity, acting coordinatewise. Write

    A_j = J_j + K_j,       kappa_j = ||K_j||_HS,
    S = sum_j kappa_j,     Q = sum_j s_j^2.

Here J_j is a signed coordinate injection: each old coordinate is copied,
possibly negated, into one distinct new coordinate, and the other new
coordinates receive zero. Ordinary signed permutations are included.
Dropping coordinates is also harmless; then J_j is a partial coordinate
isometry of operator norm at most one. No coordinate can be copied twice.

Assume both entering preactivation means and resulting state means obey

    ||h_0(x)||_2 <= 1,
    ||A_j h_(j-1)(x)||_2 <= 1,   ||h_j(x)||_2 <= 1      (1)

for every j and x. For example, (1) follows if all A_j are contractions
and the initial norm is at most one. More generally a fixed numerical bound
in (1) only changes the constants below.

Suppose each initial coordinate has an exact deterministic arithmetic formula
of size at most T0>=1. Then there are input-independent random scalar
arithmetic formulas Y_(j,i)(x), separately for every state coordinate, with

    E Y_(j,i)(x) = h_(j,i)(x),
    sum_i E Y_(j,i)(x)^2 <= 2,
    max_i E size(Y_(j,i)) <= C T0 exp[C(S+Q)].         (2)

Only a pointwise trace second-moment bound is required: (2) does not assume
that the sum of the coordinatewise suprema over x is small. Distinct child
samples are independent. Where an identity requires two occurrences of the
same sample, the already realized scalar child formula is copied syntactically
and its full size is charged again. There is no shared vector subcomputation.
Size in (2)--(3) permits complex arithmetic with a real final output; the
finite-bit conclusion includes conversion to real arithmetic formulas.

For a linear readout z(x)=v dot h_H(x), one additional sampled linear
combination gives an unbiased scalar formula Y with

    E Y(x)^2 <= 2 ||v||_2^2,
    E size(Y) <= C T0 exp[C(S+Q)].                    (3)

Consequently a globally unit-margined classifier z has a correct classifier
that is a majority of signs of rational arithmetic formulas, of total size

    poly(log|X|+1, T0, ||v||_2) exp[C(S+Q)],          (4)

after the finite-bit qualification in Section 6. On the Boolean cube, if
all displayed resources and dimensions are polynomial in an ambient R and
S+Q=O(log R), the classifier belongs to nonuniform PNC1, hence L/poly,
using the same arithmetic-formula evaluation theorem as
`fourier-poisson-finite-bit-completion.md`.

The physical Frobenius product of the supplied trajectory can be much larger:
even an identity matrix has Frobenius norm sqrt(m). Formula (4) charges its
copy operation at zero multiplicative cost.

## 2. The invariant and a cost convention

At a given stage write

    mu_i(x)=E X_i(x),
    V_i(x)=E X_i(x)^2,
    sum_i V_i(x)<=V,
    max_i E size(X_i)<=T.

V is one deterministic number, while V_i(x) can depend on x. Always maintain
T>=1. Choosing an index, a Bernoulli outcome, a frequency, or a Poisson count
selects the random expression's shape; it is not a gate evaluated on the input.
Each actually constructed arithmetic operation and every child formula is
charged. Returning an existing child formula without adding a node has no
additional arithmetic cost. This is the same nonuniform random-formula model
as in the Fourier--Poisson theorem.

A signed coordinate injection merely relabels these formulas and possibly
changes a sign coefficient; its trace moment is at most V. Zero coordinates
are exact zero formulas. A sign change can be absorbed into the next incoming
coefficient or leaf coefficient, so repeated free sign changes do not create
a linear number of extra unary nodes.

## 3. A Hilbert--Schmidt perturbation costs 1+O(kappa)

For a nonzero row i of K, put b_i=sum_j K_ij^2. Choose an index J with

    Pr(J=j)=K_ij^2/b_i

over its nonzero entries, and define

    Z_i = K_iJ X_J / Pr(J=J).

Then E Z_i=(K mu)_i and, importantly,

    E Z_i^2
       = b_i sum_(j:K_ij!=0) V_j(x)
       <= b_i V.

Consequently

    sum_i E Z_i^2 <= kappa^2 V,                     (5)

without a dimension factor and without coordinatewise uniform moment budgets.
Each nonzero Z_i has expected size at most T+O(1).

For 0<kappa<=kappa0, take p=kappa, independently for each requested scalar
formula. With probability 1-p return the corresponding copied child
(J X)_i. With probability p return an independent copy of that child plus
Z_i/p. New, uncopied coordinates have zero as their first term. The result
Y_i is unbiased for (A mu)_i. Summing its second moments yields

    sum_i E Y_i^2
      <= V + 2 <J mu,K mu> + kappa^2 V/p
      <= V + 2 kappa ||mu||^2 + kappa V
      <= V + 3 kappa V.                             (6)

We used ||mu||^2<=V and ||J||op<=1. Its common per-coordinate expected size is

    T_new <= T(1+C kappa),                          (7)

since only the rare branch constructs the extra child and arithmetic nodes.
No independent copies of all coordinates are evaluated by one formula.

For kappa>=kappa0, use p=1. Equations (5)--(6), with the obvious kappa^2 term,
give trace moment at most C(1+kappa)^2 V and expected size at most C T.
By averaging C(1+kappa)^2 independent copies coordinatewise, return the trace
moment to at most 3/2 whenever V<=2 and the true new mean norm is at most one.
The size multiplier is polynomial in 1+kappa; its logarithm is O(kappa) for
kappa>=kappa0. Thus large perturbations have the same exponential-budget
accounting as the small ones.

## 4. Coordinatewise tanh needs no vector sharing

Use the exact residual formula of
`fourier-poisson-residual-composition-audit.md`. For each coordinate separately,
draw omega with density

    omega^3 / [2 sinh(pi omega/2)]

and K~Pois(lambda), where lambda=1+omega^2 s^2 V. Construct fresh independent
copies of X_i and put

    Z_i = product_(a=1)^K (1+i omega s X_(i,a)/lambda),
    L_i = (omega s/lambda) sum_(a=1)^K X_(i,a),
    R_i = 2[Im Z_i-L_i]/(s omega^3),                 (8)

with the s=0 case omitted. Every coordinate is a separate scalar expression.
Crucially, the occurrence of X_(i,a) in L_i is a full syntactic copy of the
same realized scalar formula used in Z_i, with its constants and randomness
fixed. Replacing it by a fresh independent sample would destroy the moment
cancellation. Charging each occurrence separately multiplies the conditional
formula size by at most a constant; no DAG sharing is used.

The exact Poisson moment identity, applied with its actual V_i(x), gives

    E R_i = phi_s(mu_i)-mu_i,
    E R_i^2 <= C s^4 V_i(x)^3.                      (9)

To check the uniform use of lambda: in the identity's notation,
u_i^2<=omega^2 s^2 V_i and
v_i=omega^2 s^2 V_i/lambda<=min(omega^2 s^2 V_i,1).
For omega s sqrt(V_i)<=1 the four nonnegative terms are all sixth order;
for larger values the second moment is O(omega^2 s^2 V_i), which is bounded
by its sixth power. Division by s^2 omega^6 gives (9).

Summing (9) and using only the pointwise trace bound gives

    sum_i E R_i^2 <= C s^4 sum_i V_i(x)^3
                   <= C s^4 V^3.                   (10)

When s^2 V<=1, (8) has expected size at most C T: the frequency-averaged
Poisson rate is 1+8s^2 V. For sufficiently small s^2, choose p=s^2 V. Return
an independent X_i when a Bernoulli(p) branch is absent and return
X_i+R_i/p when present. Because

    sum_i mu_i [phi_s(mu_i)-mu_i] <= 0,

the resulting trace moment and common coordinate cost obey

    V_new <= V+C s^2 V^2,
    T_new <= T(1+C s^2 V).                          (11)

There is no shared-state/DAG step in (8)--(11). The obstruction for arbitrary
dense spectral-norm-one maps lies in their linear propagation, and Section 3
resolves precisely that step for near-copy maps.

For s^2 above a fixed small threshold, use the ordinary non-residual Poisson
tanh estimator with frequency density omega/sinh(pi omega/2). Its separate
coordinate moment bound is C V_i and its common expected cost is
C(1+s^2 V)T. Average a fixed number of independent copies to restore trace
moment at most 3/2. The logarithm of this multiplier is O(s^2) above the
fixed threshold. This covers arbitrary s>=0.

## 5. Resets, final readout, and all-cube derandomization

For any coordinate family of mean vector mu with ||mu||<=1, the average of
two independent copies has trace second moment at most

    (V+||mu||^2)/2 <= (V+1)/2.                     (12)

Choose the small-step thresholds so that a single update in (6) or (11)
raises V by at most 1/4 while V<=7/4. Whenever the deterministic upper bound
first exceeds 7/4, apply (12); the result has V<=3/2. Each reset requires an
increase of at least 1/4 since the previous reset, while the small-step
increase is bounded by C(kappa+s^2). Hence the number of resets is at most
C(S+Q)+C. Their constant size factors and (7), (11), together with the
large-step bounds, prove (2). Assumption (1) supplies the bounded mean needed
after both the linear and activation updates.

For v!=0 choose I with probability v_i^2/||v||^2 over nonzero entries and
return v_I Y_I / Pr(I=I). Then

    E Y=v dot h_H,
    E Y^2 = ||v||^2 sum_(i:v_i!=0) E Y_i^2
            <=2||v||^2,

which proves (3). This last sampling also needs no coordinatewise supremum
budgets and no dimension factor. A globally unit-margined z necessarily has
||v||>=1 under (1).

Average O(||v||^2) independent copies per group. Chebyshev gives probability
at least 9/10 of numerical error below 1/2 at a fixed x. Use
O(log|X|+1) independent groups and majority-vote their signs. The union bound
and a size Markov bound give a positive-probability realization that is correct
on all X, has a fixed fraction of good groups at every x, and has total size
bounded by (4). These good group outputs remain at absolute distance at least
1/2 from zero; only those groups need to retain their signs after rounding.

## 6. Finite bits and the scope of the PNC1 corollary

For the Boolean-circuit corollary assume dimensions, depth, T0, ||v||, and
the initial formulas' coefficient sizes and bit lengths are polynomial in R,
with S+Q=O(log R). The A_j and s_j need not initially have short descriptions,
since the conclusion is nonuniform. They can be replaced by suitable
polynomial-bit approximations before applying the formula construction.

Indeed the original linear gains are at most 1+kappa_j, and the activations
are one-Lipschitz. Thus a per-stage perturbation delta changes every state by
at most C H delta exp(S), provided all states remain in a fixed-radius ball.
Uniformly on that ball,

    |phi_s(u)-u| <= C s^2 |u|^3,

so scales with s^2 below an inverse-polynomial cutoff can be deleted, with
the same total error accounting. Round each retained K_j entry on an
inverse-polynomial mesh; its matrix error is at most the mesh times the
maximum dimension. Round positive s_j in its polynomial range on a sufficiently
fine inverse-polynomial mesh. Standard differentiation, or the tanh mean-value
bound, gives a polynomial modulus in s on the fixed ball. Round v similarly.
Take all these errors small enough to leave readout margin at least 3/4.
The rounded trajectories satisfy a fixed mean-norm bound such as two, which
only changes the constants in Sections 3--5. Rescale the final readout to
restore unit margin if desired.

All nonzero retained matrix entries and s_j are now inverse polynomially
bounded; row sampling probabilities, nonzero small-step branch probabilities,
and their reciprocals have polynomial range. Global deterministic trace
budgets can be rounded upward on fixed inverse-polynomial meshes, charging
their aggregate slack to a constant. Large-step averaging counts are polynomial.

Frequency densities have exponential upper tails and polynomial mass near
zero. At a polynomial bound on realized formula size, all frequencies can
be restricted, with arbitrarily high fixed probability, to
[R^-C,C log R]. The same expected-node/union-bound truncation used in the
existing finite-bit completion then bounds every realized coefficient by
exp(poly(R)). Poisson counts contribute that many actual product leaves, so
the realized size bound also bounds their counts. A finite arithmetic formula
of polynomial size with coefficients of polynomial logarithmic magnitude
can be rounded to polynomially many bits while preserving the signs of its
good, uniformly margined group outputs on all Boolean inputs. Complex factors
can be converted to real arithmetic formulas by the same complex-expression
balancing lemma used in that completion.

This yields polynomial-size rational arithmetic sign formulas followed by a
polynomial majority. The existing PNC1 composition theorem places that
classifier in nonuniform PNC1. This is an arithmetic-formula result, not a
claim of Boolean NC1.

## 7. What this does and does not repair

The earlier residual-DAG theorem permits arbitrary contraction matrices but
shares one vector child among many outgoing coordinates. Expanding that DAG
can be expensive. Here a common maximum scalar-coordinate cost and a
pointwise trace-moment invariant are enough because each large linear part is
an actual coordinate copy, and the remaining part is charged by its
Hilbert--Schmidt norm. That is the new restriction and the new conclusion.

The critical canonical linear maps are general isometries plus small
Hilbert--Schmidt perturbations. A basis change can make an isometry a copy
map, but it generally destroys coordinatewise tanh structure. The canonical
residual-radius coordinate also remains nonsmooth. Therefore one cannot
apply this theorem to those maps simply by choosing convenient bases.

A feature representation preserving both cheap copying and an economical
nonlinear scalar-coordinate transform would be sufficient for the critical
PNC1 transfer. Gaussian/Fock features are one candidate, but their variance
and coefficient dependence on query norms have not been controlled here.

