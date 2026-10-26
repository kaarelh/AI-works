# Quadratic variance occupation for equal-diagonal Gaussian Fock layers

26 October 2026. Scratch improvement to `gaussian-fock-scalar-formulas.md`.
This is an exact scalar-formula lemma for its equal-diagonal compatible-
coordinate setting. It does not provide the general variable-diagonal or
non-Gaussian posterior bridge.

## 1. Improved sparse-coordinate construction

Write

    G_q(u)=direct-sum_(k odd>=1) b_k(q) u^(tensor k),   ||u||=1,
    sum_k b_k(q)²=1,
    sum_(k>=3) k² b_k(q)²<=6q².

The last estimate is the exact Gaussian Sobolev identity proved in the
earlier note. Suppose coordinate oracles X_i are unbiased for u_i, have
pointwise trace second moment at most V>=1, and each has expected formula
size at most T>=2. All child calls below are independent. A returned zero
has size one; degree-one copies combine their scalar edge coefficient
without introducing a new recursive call or an extra node per layer.

For every k>=3 put

    m_k=ceil(kV),      p_k=1/(C_* k² V),                     (1)

where C_* is a fixed sufficiently large numerical constant. For ordered
coordinate word I=(i_1,...,i_k), return zero with probability 1-p_k and
otherwise return

    [b_k(q)/p_k] product_(a=1)^k Xbar_(i_a),                 (2)

where each Xbar is an independent average of m_k copies. This is unbiased.
The mean-state norm is exactly one, so

    sum_i E Xbar_i²<=1+(V-1)/m_k,
    [sum_i E Xbar_i²]^k<=e.                                (3)

There is a universal arithmetic-accounting constant C0 such that the
nonzero branch has expected size at most C0 k m_k T. Since m_k<=2kV,
the entire new coordinate has expected size at most

    1+C0 p_k k m_k T <=1+(2C0/C_*)T <=T,                   (4)

provided C_*>=4C0 and T>=2. At degree one simply return b1(q)X_i,
which has size at most T. Thus the common expected coordinate-size bound
does NOT increase at an ordinary Gaussian feature step.

Summing second moments over all ordered words, Tonelli and (3) give

    V_new<=b1(q)² V+e sum_(k>=3)b_k(q)²/p_k
          <=V[1+C1 q²],                                  (5)

for a universal C1. This is the improved point: the higher-degree
coordinates are new orthogonal coordinates. They do not contain an old
coordinate that must also be evaluated on their zero branch. Their sparse
branch probability can therefore be independent of q. The small Hermite
coefficients themselves supply the q² trace charge.

## 2. Resets and composition

For q² small enough that C1q²<=1/8, maintain the deterministic trace bound
below 7/4. When an update first exceeds 7/4, it is still below two. Replace
every coordinate by the average of two independent copies; since the true
mean-state norm is one, its new trace bound is at most (V_new+1)/2<=3/2.
The expected size multiplier of this reset is at most three. Between
resets the trace must increase by at least 1/4, while each increase is at
most C q². Therefore the number of such resets is at most
C sum_j q_j²+C, and

    max_i E size(X_i,final)<=C T0 exp(C sum_j q_j²),
    sum_i E X_i,final(x)²<=2.                               (6)

Large-q steps cause no gap. If V<=2, (5) gives V_new<=2(1+C1q²).
Averaging ceil(2V_new) independent copies reduces the trace bound to at
most 3/2. Its expected-size multiplier is polynomial in 1+q², whose
logarithm is at most Cq² once q² is above the fixed small-step cutoff.
Consequently (6) holds for arbitrary positive q_j.

The existing signed-coordinate-copy plus Hilbert--Schmidt perturbation
lemma composes unchanged: a small charged perturbation K raises the
variance budget by O(||K||HS) and multiplies common expected size by
1+O(||K||HS), with large controls charged as before. Thus its exact
real-formula conclusion improves to

    expected size <= C T0 exp[C(S+Q2)],
    S=sum_j ||K_j||HS,   Q2=sum_j q_j²,                      (7)

under the same unit-mean-norm and compatible-coordinate hypotheses.
An l2 readout, finite-input simultaneous fixed-seed selection, and the
already proved moment-floor finite-bit machinery can be applied exactly
as in that restricted Gaussian construction. In (1), V stays bounded
between resets, so 1/p_k is only a fixed multiple of k²; there is no
new inverse-small-q precision issue.

## 3. Boundary interpretation and limits

For an uncontrolled equal-diagonal Gaussian tanh chain at t=1+delta,
the free variance estimate q_j<=C[delta+1/(j+1)] gives

    sum_j q_j²<=C(1+delta²H).

Hence this exact Gaussian Fock feature/readout class has formula resource
exp[O(1+delta²H)], up to its initial and readout polynomial resources.
This matches the quadratic free-correlation timescale rather than the
linear full-norm gain t^H. It is not an actual posterior theorem: margin
conditioning changes row laws, physical readout normalization matters,
and a general controlled path may have query-dependent variances.

In the variable-diagonal Gaussian compiler, the scalar variance oracle
and its normalization helpers still have an O(q) update in the existing
proof. The present orthogonal-coordinate observation does not eliminate
that cost. It also does not address arbitrary finite-entropy non-Gaussian
tilts or settle the original canonical Boolean tanh depth problem.
