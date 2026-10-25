# Finite-width covariance extraction with logarithmic tolerance cost

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Statement

Let Z contain m >= 1 inputs and k=m(m+1)/2. Consider a width-N network with H
hidden tanh layers. Given all previous hidden blocks, the current hidden rows
are independent Gaussian feature rows with reference preactivation law mu_j^G
=N(0,t² Q_{j-1}), where Q_{j-1} is the empirical previous feature covariance
on Z. The first-layer covariance may be any prescribed Gaussian covariance;
the proof does not require the same prefactor in that layer. Suppose the
readout, given the hidden blocks, has covariance t_out² Q_H/N, t_out>0, and set

    r(z,Q_H) = (1/(2 t_out²)) z^T Q_H^dagger z.

For any measurable event E with raw prior probability at least exp(-N A), any
0<tau<=1, and any 0<Delta<=1, there is a realization in E and controlled laws
rho_j << mu_j^G whose feature moment matrices satisfy

    max_entry | E_rho_j[tanh(G)tanh(G)^T] - Q_j | <= Delta,
    sum_j KL(rho_j || mu_j^G) + r <= A+tau,

provided

    N >= C/tau * [H k log(1 + C (A+1) H k/(Delta tau))
                  + m log( C(A+1)/tau ) + 1].

Here C is universal. There is no inverse polynomial Delta factor: only
log(1/Delta) occurs. No exchangeability hypothesis on E is needed. No output
margin is needed for the extraction itself; a margin event retains its actual
realized outputs z.

The conclusion is on the selected witness Z. In an exceptional-mass argument,
m is later chosen to be a polynomial VC witness size; it is not set equal to
the whole cube size 2^d.

## 1. A bounded dual and its exact tilted-law certificate

For any probability law mu on bounded feature vectors h in [-1,1]^m, let
phi(h) be the k upper-triangular products h_x h_y. Every coordinate of phi is
in [-1,1]. Define

    Lambda_mu(lambda) = log E_mu exp(lambda dot phi),
    I_B(q;mu) = max_{lambda in [-B,B]^k}
                   [lambda dot q - Lambda_mu(lambda)].

The maximum exists by continuity. Lambda is smooth because phi is bounded.
At a maximizer lambda*, define the exponential tilt

    dnu/dmu = exp(lambda* dot phi - Lambda_mu(lambda*)).

Write a=E_nu phi=grad Lambda_mu(lambda*). Box optimality gives

    lambda*_i (q_i-a_i) = B |q_i-a_i|    for every i.

Indeed, an interior coordinate has q_i=a_i, and an upper/lower boundary
coordinate has the matching sign. Consequently

    I_B(q;mu) = KL(nu||mu) + B ||q-a||_1.                 (1)

This is an explicit certificate; no limiting convex-duality argument is
required. In particular I_B>=0 (lambda=0 is allowed), and

    KL(nu||mu) <= I_B,   ||q-a||_1 <= I_B/B.              (2)

When mu is tanh_* mu^G, the same tilt composed with tanh defines a law rho
absolutely continuous with respect to mu^G. Its KL is exactly the feature
KL, since coordinatewise tanh is injective on R^m. Singular reference
Gaussians cause no change.

## 2. A uniform finite-sample exponential moment

Let h_1,...,h_N be iid mu and qhat=N^{-1} sum_i phi(h_i). Fix a finite grid
Gamma in [-B,B]^k with l_infinity covering radius eta. It may be chosen with

    |Gamma| <= (1+2B/eta)^k

after a harmless universal adjustment of the grid-spacing constant. The
objective lambda dot qhat - Lambda(lambda) is 2k-Lipschitz in l_infinity,
because both qhat and grad Lambda lie in [-1,1]^k. Thus

    I_B(qhat;mu) <= max_{lambda in Gamma}
                       [lambda dot qhat-Lambda(lambda)] + 2k eta.

For every fixed lambda,

    E exp(N[lambda dot qhat-Lambda(lambda)]) = 1.

Taking a sum over the grid proves

    E exp(N I_B(qhat;mu)) <= exp(2N k eta) |Gamma|.       (3)

The bound is uniform in mu. In a neural layer, mu may therefore depend
arbitrarily on all previous hidden blocks.

## 3. Conditional multiplication across the network

Let I_j=I_B(qhat_j;mu_j), where qhat_j lists Q_j and mu_j is its conditional
Gaussian-tanh reference. Iterating (3) gives a bound on exp(N sum_j I_j).
For the actual Gaussian readout, for 0<s<1,

    E[exp((1-s)N r) | hidden blocks]
       = s^{-rank(Q_H)/2} <= s^{-m/2}.

The equality includes singular Q_H; the actual output belongs to its range.
Combining with the hidden-layer iteration,

    E_prior exp(N [sum_j I_j + (1-s)r])
       <= exp(2NHk eta) |Gamma|^H s^{-m/2}.             (4)

This uses only the original forward conditional product structure of the
prior. It does not condition a layer on future weights and does not require
the event E to preserve row permutations.

## 4. Selecting a realization inside the event

Set P=prior(.|E), so KL(P||prior)<=NA. Entropy duality applied to (4) gives

    E_P[sum_j I_j + (1-s)r]
       <= A + 2Hk eta + [H log|Gamma|+(m/2)log(1/s)]/N. (5)

Take, for example,

    s = tau/[16(A+1)],
    eta = tau/(64 H k),
    B = (A+1)/Delta.

Require

    N >= (16/tau) [H log|Gamma|+(m/2)log(1/s)+1].

Then the right side of (5) is at most A+3tau/32. Some realization in E has
the displayed nonnegative cost at most A+tau/8 (or any slightly larger
bound). Since I_j>=0,

    (1-s)(sum_j I_j+r) <= sum_j I_j+(1-s)r,

and therefore the realization can be selected with sum_j I_j+r<=A+tau.
One can use the numerical constants above directly; they leave ample slack.
Apply (1) separately at every layer of this realization. Since each I_j is
at most the total A+tau<=A+1, its moment l1 error is at most Delta and its
KL is at most I_j. This proves the statement.

## Consequence for a fixed subcritical prefactor

If a population compression argument requires absolute covariance tolerance

    Delta >= exp(-C_t H) * poly(resources)^{-1},

then this extraction lemma still requires only polynomial width in H and the
resources (with constants allowed to depend on fixed t>0). Thus exponentially
small intermediate covariance scales do not alone create a finite-width
obstruction. One must still prove the population compression theorem, the
target-mass theorem, and their depth/resource bounds; this certificate supplies
only the finite-width extraction step.

For the original t=1 critical model it also strictly improves the stated
tolerance dependence of the existing extraction lemma, while leaving its
subsequent exponential-in-square-root-excess population capacity factor intact.

## Arbitrary action slack and uniform small-prefactor bookkeeping

The restriction tau<=1 above is unnecessary. For every tau>0 take instead

    s = tau/[16(A+tau)],
    eta = tau/(64 H k),
    B = (A+tau)/Delta.

Then s<=1/16 and B/eta>=64Hk, so the same grid estimate applies. The same
proof gives total cost <=A+tau and moment error <=Delta provided

    N >= C/tau * [Hk log(1+C(A/tau+1)Hk/Delta)
                  + m log(C(A/tau+1)) + 1].

For the final rescaling check,

    (A+tau)(1-s)=A+15tau/16,

whereas the selected unrescaled cost is at most A+tau/8. Thus the numerical
slack is uniform even for large tau.

This extension was independently checked with the complexity-barrier agent.
For a common Gaussian prefactor 0<t<=1, setting tau=t^(-2) makes the width
prefactor 1/tau=t². If a consistent-path transfer needs

    log(1/Delta) <= C[H|log t|+log(poly(d,H,m,1+t²A,P))],

then the apparent singularity in the extraction threshold is harmless:
t²|log t|<=1/(2e). The rest depends polynomially on d,H,m,1+t²A,P with
universal constants. Integer width N>=1 can be imposed separately.

The companion normalized population compression uses layer-specific anchor
thresholds delta_j=epsilon0² R(D_j), where R-1-log R=2D_j. Its anchor count
is at most H/(2epsilon0²), because D_j/R(D_j)<=1/2. The Gaussian maximum
factor is also normalized:

    (d+D_j+1)/R(D_j) <= d+3/2.

Consequently its dependence on the raw action A can be replaced by dependence
on 1+t²A. Combined with the arbitrary-slack certificate, this is the basis
for the intrinsic theorem in `fixed-t-compression.md` and its scale-uniform refinement in `uniform-scale-intrinsic.md`.
