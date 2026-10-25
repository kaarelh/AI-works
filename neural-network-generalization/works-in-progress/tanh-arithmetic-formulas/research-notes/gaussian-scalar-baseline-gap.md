# The Gaussian scalar baseline is strictly larger

25 October 2026. Scratch proof; no numerical premise. This corrects the
nonvacuity interpretation of the Gaussian-control companion. All constants
below are universal. Gaussian controls include arbitrary means and positive
variances.

## 1. Values and transition costs

For a scalar path starting at q>0, write q_0=q and

    q_j = E_{eta_j} tanh^2 Z,
    A = sum_j KL(eta_j || N(0,q_{j-1})) + 1/(8 q_m).

Let V(q) be the infimum over all finite paths, including length zero, and
V_G(q) the same infimum restricted to Gaussian eta_j. Set

    V_* = lim_{q downarrow 0} V(q),
    V_*^G = lim_{q downarrow 0} V_G(q).

The existence of the second limit and its boundedness are proved in Section 4.
In particular both values are below 2. Define, for p>0 and r in (0,1),

    I_p(r) = inf { KL(eta || N(0,p)) : E_eta tanh^2 Z = r }.

Writing g(z)=tanh^2 z and
Lambda_p(theta)=log E_{N(0,p)} exp(theta g(Z)), one has

    I_p(r) = theta r - Lambda_p(theta),
    Lambda'_p(theta)=r.

Indeed Lambda''_p(theta)>0, and Lambda'_p maps the real line onto (0,1).
The unique minimizer is

    d eta_{p,r} / d N(0,p) = exp(theta g - Lambda_p(theta)).

These assertions follow directly from the entropy identity

    KL(eta || N(0,p)) = I_p(r) + KL(eta || eta_{p,r})

for every eta with E g=r. The optimizer and I_p(r) vary continuously with
(p,r) in (0,infinity) x (0,1), by the implicit function theorem. This is
ordinary finite-dimensional continuity; no optimizer compactness assumption
is being imported.

## 2. A uniform positive saving at one macroscopic crossing

Put b=1/16 and a=b/10=1/160. Let S be the set of triples (p,m,v) satisfying

    a <= p <= b,  v>0,
    D(p,m,v) := [m^2/p + v/p - 1 - log(v/p)]/2 <= 2,
    r(m,v) := E_{N(m,v)} tanh^2 Z >= b.

This is a nonempty compact subset of (0,infinity) x R x (0,infinity).
For nonemptiness one may take p=b and v=(1+6b)b, m=0; the Gaussian
growth inequality used below gives output strictly above b and entropy
less than two.
To check compactness, D<=2 implies m^2/p<=4 and
s-1-log s<=4 for s=v/p. The latter confines s to a compact subinterval of
(0,infinity). Since p is bounded away from zero, so is v. The continuous
function r is strictly below 1 at every point, hence its maximum on S is
also strictly below 1.

Define the following explicit, finite-dimensional universal constant:

    delta := min_{(p,m,v) in S} [D(p,m,v) - I_p(r(m,v))].             (1)

Then delta>0. The quantity minimized is nonnegative by the entropy identity
and continuous by Section 1. If it were zero at some triple, N(m,v) would
equal eta_{p,r}. Its log density ratio relative to N(0,p) is a quadratic
polynomial in z, whereas theta tanh^2 z-Lambda_p(theta) is bounded on R.
Equality forces the quadratic and linear coefficients to vanish, giving
N(m,v)=N(0,p) and theta=0. But then

    r = F(p) := E tanh^2(sqrt(p) Z) < p <= b,

contrary to r>=b. Equality almost everywhere suffices, since the two log
density expressions are continuous. Compactness now proves strict positivity
in (1). Equation (1) is a rigorous quantitative definition of the gap
constant; this note does not claim a decimal lower bound.

## 3. Strict separation of the two baselines

For every 0<q<a,

    V_G(q) >= V(q) + delta.                                      (2)

Take a Gaussian scalar path from q with total cost less than 2. Its final
state exceeds b, since otherwise its readout alone costs at least 2. At its
first crossing of b, let p<b be the preceding state and r>=b the new state.
The preactivation second moment is at least r. If p<a, its ratio to p is
greater than 10, and Gaussian entropy duality gives

    D >= (10-1-log 10)/2 > 2,

impossible. Thus the transition belongs to S. Replace just this Gaussian
law by eta_{p,r}. Its post-state is exactly unchanged, so every later
control and the readout can be kept. The entropy saving is at least delta,
proving V(q)<=A-delta.

Gaussian paths with cost less than 2 approximate V_G(q), because the
explicit Gaussian growth construction in critical-rate-foundations.tex has
cost at most

    U = 199/200 + log(5/2) < 2.

Taking infima proves (2), and letting q decrease to zero yields

    V_*^G >= V_* + delta > V_*.                                  (3)

This proof allows nonzero Gaussian means. Finite-step strictness alone would
not prove (3); the forced crossing of a fixed compact state interval is the
reason the saving cannot disappear in an arbitrarily long path.

## 4. The Gaussian value has its own Bellman and occupation bounds

Every proof of the following scalar facts stays inside the Gaussian class:

    V_G is nonincreasing;  V_G(q)<=1/(8q);  V_*^G<=U<2;
    0 <= V_*^G - V_G(q) <= 17 q       for 0<q<=1/128.              (4)

For monotonicity, scale each control by the square root of the ratio of
the new and old reference variances. Gaussian laws remain Gaussian,
relative entropy is unchanged, and each feature variance increases.
Deleting nonincreasing steps uses the same scaling and also preserves
Gaussianity. The upper bound U uses only centered Gaussian variance
inflations. The small-state bridge in the same source uses
N(0,(1+16q)q), costs at most 64q^2 per step, and advances variance by at
least 4q^2 while q<=1/128. Stopping exactly at a prescribed p costs at
most 17p; append a Gaussian nearly optimal suffix and let the initial
state tend to zero. This proves the final inequality in (4), as well as
existence and finiteness of the limit. Enlarging 17 to 256 extends it to
0<q<=2.

Appending Gaussian suffixes gives the Gaussian Bellman inequality

    D >= V_G(p)-V_G(r)

for every Gaussian transition p->r. The already proved strict scalar
dissipation inequality is valid for all laws and therefore also gives

    D >= r-p+c p^2,       0<p<=2,                                (5)

after decreasing the universal c if needed.

Now consider an actual full-cube Gaussian-controlled path of H>=1 hidden
steps, initial kernel (1+x dot y)/d, margin at least 1/2 at every input,
and action A=sum D_j+||v||^2/2. A projection of each Gaussian row law onto
one input is Gaussian, with projected entropy at most D_j. Cauchy--Schwarz
for the final readout gives the scalar terminal cost 1/(8q_H(x)). Hence
for every input x and every prefix i,

    sum_{j<=i} D_j <= A - V_G(q_i(x)).                            (6)

This is the actual controlled-kernel semantics, not an additional
Gaussian approximation. For q_i=max_x q_i(x), choose an input attaining
the maximum at the end of the relevant prefix/suffix. Equation (6) and
the monotonicity argument for (5) give precisely the hypotheses of the
existing variance/entropy occupation proof, with V_G in place of V.
Consequently, if A<=V_*^G+epsilon, epsilon>=0,

    sum_{j=0}^{H-1} q_j + sum_{j=1}^H sqrt(D_j)
      <= C [log(H+2)+sqrt(H epsilon)],
    sum_j D_j <= V_*^G+epsilon <= U+epsilon.                     (7)

The initial diagonal (d+1)/d<=2 is covered by (4)--(5). No equal-diagonal
assumption is imposed on subsequent layers.

The Gaussian formula compiler therefore has a valid own-baseline
corollary: such a path has rational arithmetic-formula majority resources
bounded by a fixed polynomial in d+H+epsilon+2 times

    exp{ C [log(H+2)+sqrt(H epsilon)+epsilon] }.                  (8)

In particular, when the displayed resource is polynomial in an ambient
parameter, the classifier belongs to PNC^1 and hence L/poly. The direct
entropy-budget theorem of the Gaussian companion is unchanged. What
must change is the reference baseline in its intended nonvacuous
near-baseline corollary.

## 5. The unrestricted-baseline Gaussian corollary is eventually empty

Uniformly in d and the Boolean target f, the Gaussian-restricted
H-hidden-layer action infimum satisfies

    J_H^G(f) >= V_*^G - C/H >= V_*+delta-C/H.                     (9)

For completeness, fix any input and write q_i for its variances. If
A>V_*^G the first inequality is immediate. Otherwise (6) and (4) imply
prefix entropy <=C_0 q_i, while total entropy is less than 2. Together
with (5), the last-exit occupation lemma from
critical-rate-lower-proof.tex gives min_i q_i<=C/H. That proof uses only
the displayed inequalities and extends verbatim from q_0<=1 to q_0<=2:
the initial higher range changes only its bounded tail constant. At an
index attaining the minimum, the Gaussian scalar suffix costs at least
V_G(q_i)>=V_*^G-C_0 q_i, proving (9). Taking an infimum does not require
attainment.

Thus the subclass satisfying A<=V_*+epsilon is empty whenever

    epsilon < delta-C/H.

In particular it is empty for any epsilon_H->0 along H->infinity.
The earlier implication for that subclass was formally correct, but
cannot supply a substantive asymptotic Gaussian endpoint result. The
replacement (7)--(8) uses the Gaussian class's own scalar baseline.

## 6. Attainability from the prescribed input

The scalar Gaussian class itself attains its own baseline asymptotically,
by the definition of V_G and the Gaussian increasing-path reduction.
Its nearly optimal paths can be chosen with length O(1/p) and state sum
O(log(1/p)) when started at p, by the existing dyadic argument with
(4) in place of its unrestricted counterpart.

Attainability from the prescribed augmented-cube input is a separate
construction, checked in `gaussian-own-baseline-nonvacuity.md`. It gives

    J_H^G(f) <= V_*^G + C [S_f^2+log^2(2H)]/H,   H>=C S_f,
    S_f=1+log(1/a_f),  a_f=(f^T Q1^{-1} f)^{-1},

where Q1 is the first free Gaussian tanh kernel. Free cooling, target
holding/growth, and purification use Gaussian covariance inflation only.
The scalar suffix can be chosen Gaussian by (4), and its stable lift
rescales the scalar law and independently adds a residual Gaussian.
Consequently the whole construction stays within the Gaussian class.
One has S_f<=15(d+1), and constants/dictators have S_f=O(log(d+1)).
Together with (9), this proves that every fixed target's deep Gaussian
rate limit is exactly V_*^G. Constants and dictators attain the
polynomial-resource range of (8), so the corrected own-baseline
corollary is genuinely nonvacuous on the actual augmented-cube input.

The independent numerical experiment reported by the parent suggests
V_* approximately 1.1210 and V_*^G approximately 1.1539. Those numbers
are exploratory and are not used in any argument here.
