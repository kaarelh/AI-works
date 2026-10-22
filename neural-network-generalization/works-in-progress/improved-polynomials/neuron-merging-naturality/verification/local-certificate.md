# A local certificate for a quadratic-width robust prior

Research derivation, 22 October 2026 (UTC). This is not Lean formalized.

The population-averaging theorem assumes that some small quotient network
approximately preserves clipped outputs. A more local sufficient condition
checks discrepancies between the incoming population sums of neurons in
the same group. This is an approximate equitable-partition, or lumpability,
condition. It avoids testing final output agreement directly, but it is
still a substantive structural assumption about neuron redundancy.

## Signed population projections

At each hidden stage s, partition the N neurons into q nonempty groups and
assign each neuron a sign sigma_i in {-1,+1}. Define the orthogonal
projection P_s by

    (P_s h)_i = sigma_i / |group(i)|
                  * sum_{j in group(i)} sigma_j h_j.

Groups may have unequal sizes. The range consists of signed group-constant
vectors. Since tanh is odd, tanh(P_s z) belongs to this range. In particular
the population-averaged network

    Wbar_1 = P_1 W_1,
    Wbar_s = P_s W_s P_(s-1),
    vbar = P_H v

has all its hidden states in the respective signed group-constant ranges.

## Local operator certificate

Let H=L-1 and define

    delta_1 = sqrt((d+1)/N) ||(I-P_1) W_1||_op,
    delta_s = ||(I-P_s) W_s P_(s-1)||_op,  2<=s<=H.

Suppose

    sum_s delta_s^2 <= r_c(w)^2,
    r_c(w)=c/sqrt(1+H E_v(w)),     E_v=N||v||^2.

If w satisfies the original clipped-score RMS-noise robustness condition,
then its population-averaged network obeys

    sup_x |T(zbar_w(x))-T(z_w(x))| <= 1/16.

### Proof

Let hbar_s be the population-averaged forward states. At the first layer,
define an original-network postactivation disturbance

    eta_1 = tanh(P_1 W_1 xbar) - tanh(W_1 xbar).

The 1-Lipschitz property of coordinatewise tanh and
||xbar||=sqrt(d+1) give ||eta_1||/sqrt(N) <= delta_1.

At each later layer define

    eta_s = tanh(P_s W_s P_(s-1) hbar_(s-1))
              - tanh(W_s hbar_(s-1)).

Because P_(s-1) hbar_(s-1)=hbar_(s-1) and every hidden coordinate is bounded
by one, its normalized norm is at most delta_s. The original network under
these simultaneous disturbances therefore has exactly the hbar_s states.
Its readout equals the averaged readout because

    (P_H v)^T hbar_H = v^T hbar_H.

No output disturbance is needed. The total disturbance lies inside the
original calibrated ball, so original robustness proves the conclusion.
There is no product of downstream operator norms.

The certificate is invariant under tanh sign gauges: applying a diagonal
sign matrix at each hidden stage conjugates each projection and each
residual matrix, preserving every displayed operator norm.

## Interpretation

For ordinary unsigned groups, `(I-P_s)W_s P_(s-1)` measures how much the
neurons in an output group disagree in their aggregate incoming weights
from each preceding population. It permits arbitrary weight differences
on input directions orthogonal to the preceding population subspace.
Thus it does not require whole rows of a wide weight matrix to be close in
Euclidean norm. Large within-population Gaussian bulk components may be
present and annihilated by the right projection.

This is a deterministic, label-free certificate. Given proposed groups,
the residual norms are directly computable. Finding useful groups remains
a separate algorithmic problem, and no claim is made that ordinary trained
networks satisfy the certificate.

One may replace operator norms by Frobenius norms for an easier, stronger
certificate. One may also check the actual activation defect along every
population-averaged trajectory, as described below; that is weaker than
the operator certificate but harder to certify uniformly.

## A trajectory-sensitive activation certificate

For a fixed partition and gauge, define the exact hidden merge defects

    e_1(x)=tanh(P_1 W_1 xbar)-tanh(W_1 xbar),
    e_s(x)=tanh(P_s W_s hbar_(s-1)(x))
              -tanh(W_s hbar_(s-1)(x)).

The weaker condition

    sup_x sum_s ||e_s(x)||^2/N <= r_c(w)^2

implies the same averaging guarantee by the identical exact-history proof.
This permits saturation to suppress large preactivation discrepancies.
It checks local merge errors on the actual averaged computation rather
than directly assuming the desired final output approximation.

Testing it only on a finite sample of inputs would provide empirical
evidence, not the distribution-free support guarantee used here.

## Why ordinary activation variance alone is insufficient

Small within-group variance of the original clean hidden activations does
not by itself justify averaging the incoming weights. Consider N-1 neurons
with constant preactivation M and one neuron with constant preactivation
-M^2, where M is much larger than N. Their tanh outputs are almost all +1,
with one near -1, so their within-group activation variance tends to zero
as N grows. Their average preactivation is negative and large in magnitude,
so applying tanh after averaging the weights produces almost -1.

With uniform positive readout weights this can reverse the final output.
For one hidden layer and calibration c<=1/16, the original RMS robustness
condition is satisfied by every network, so that condition does not remove
this counterexample. A useful local merging certificate must control the
merge operation itself, or preactivation discrepancies, rather than only
the variance of existing saturated activations.

## Cheap robust Boolean witnesses

The local certificate is compatible with the existing target-cylinder
construction at every N>=C, after only polynomially smaller intervals.

Use its balanced C clone groups and the ordinary positive gauge. Let the
original gate gain be A, choose readout gain `a=max(4,256c)`, and write
rho_old for the interval radius in that construction. Define

    r_low = c/sqrt(1+4H a^2 C),
    D_loc = sqrt((d+1)^2/d + (H-1)C),
    rho = min(rho_old, r_low/(2 D_loc)).

The original saturation and robustness proof remains valid because rho was
only decreased. On the cylinder, the readout obeys

    sqrt(E_v) <= a sqrt(2C)+rho <= 2a sqrt(C),

so r_c(w)>=r_low. At the first layer the teacher is constant within each
clone group and each perturbation coordinate has magnitude at most
rho t/sqrt(d). Orthogonal contraction and the Frobenius bound give

    delta_1 <= rho t (d+1)/sqrt(d).

For internal layers the decomposition is

    W_s = W*_s + R_s + E_s,
    P_s W*_s P_(s-1)=W*_s,
    E_s P_(s-1)=0,
    ||R_s||_op <= rho t sqrt(C).

Consequently delta_s<=rho t sqrt(C). Since t<=1,

    sqrt(sum_s delta_s^2) <= rho D_loc
                          <= r_low/2 <= r_c(w)/2.

The entire cylinder thus satisfies the local operator certificate with
strict slack, as well as the original robustness condition and every
training margin. Its raw probability still has the form

    exp(-N D_*/t^2),
    D_* = B_0 + [d+2+(H-1)C] log(e sqrt(2pi)/(2rho)) + log 2.

The smaller radius changes only the logarithmic interval cost. At fixed
dimension, depth and calibration, `D_*=O(C log^2(2+C))` as before. Jointly
all resources remain polynomially bounded.

## A resulting strengthened prior

Intersect the original robust support with existence of signed populations
satisfying the local certificate and the readout-scale-invariant budget

    (q-1) M_infty(w)^2 <= 4 E_v(w),
    M_infty(w)=max_x |z_w(x)|.

This division-free form also defines the zero-output case. A nonempty
exact-margin training sample implies M_infty>1/2, so the posterior readout
tail bounds q by `1+16 E_v`. The target cylinder qualifies because

    sqrt(E_v) >= a sqrt(C/2)-rho >= (5/8)a sqrt(C),
    M_infty <= a+rho <= 5a/4,
    4 E_v/M_infty^2 >= C.

The inequalities use a>=4, rho<=1/4, and C>=1. The weaker energy
lower bound a^2 C/8 alone would not suffice for this sharper constant.

The local certificate implies population-averaging stability. Therefore
the signed arbitrary-population quadratic theorem applies with the newly
computed target cost. In particular the sufficient sample dependence on
C is quadratic up to logarithms, at every N>=C and every 0<t<=1.

This does not prove that the original RMS robustness condition alone gives
a quadratic bound. It supplies a more local, checkable sufficient
restriction for the stronger structural theorem. Its practical naturalness
requires empirical investigation.

## Empirical nonvacuity

Taking q=N always makes the residual certificate zero. Such a diagnostic
therefore has evidential value only if the population count is meaningfully
smaller than N and satisfies the stated energy budget. The normalized
budget prevents enlarging q merely by rescaling all readout coefficients,
but a network with large readout cancellation may still allow q close to N.
Empirical reports should give q/N, E_v/M_infty^2, and the measured residual
budget, not only a Boolean pass/fail label.
