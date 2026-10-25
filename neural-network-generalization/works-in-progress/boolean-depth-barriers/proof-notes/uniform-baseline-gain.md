# Uniform gain after subtracting the nonlinear scalar baseline

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Claim

Let 0<t<=1, a=t^(-2)-1, H>=1, and

    c_t=(a-log(1+a))/2.

Consider a controlled tanh covariance path on a finite input witness containing
at least one input x0, with original normalized input variance
q0=Q0(x0,x0) in [1,2], hidden variances qj=Qj(x0,x0)<=1, and final output
|z(x0)|>=1/2. Let Dj be the full layer entropies relative to N(0,t²Qprev),
r_t=(2t²)^(-1) z^T QH^dagger z the full readout cost, and A=sum Dj+r_t.
Put r1=t² r_t and define

    ej = Dj-c_t-(a/2)log(qj/qprev),
    Atilde = sum ej+r1
           = A-Hc_t-(a/2)log(qH/q0)-a r1.

Then ej>=0. If Atilde<=V*+epsilon, epsilon>=0, the exact entropy-to-variance
gain, with R(D)>=1 defined by R-1-log R=2D, obeys

    sum_j log[t sqrt(R(Dj))]
      <= C log(H+2) + C min{sqrt(H epsilon), epsilon/a}.    (1)

At a=0 the second expression in the minimum is interpreted as infinity, so
the bound reduces to the critical square-root-excess estimate.

The actual action always supplies the sufficient adjusted budget

    Atilde <= A-Hc_t+a,

so epsilon=(A-Hc_t-V*+a)_+ may be used. The harmless +a can be sharpened by
retaining the terminal scalar expression. A signed cube edge gives the further
dimension subtraction (a/2)log d, but is unnecessary for witness extraction.

## Scalar identities and critical controls

Let eta_j be the one-input marginal of the controlled preactivation at x0.
It is absolutely continuous with respect to N(0,t²qprev). Gaussian references
with positive variances are equivalent, and the exact identity is

    D(eta_j || N(0,t²qprev))
      = D(eta_j || N(0,qprev)) + c_t
        +(a/2)( E_eta G²/qprev - 1).

For a one-input projection qj=E_eta tanh²(G). In a signed-pair version the
corresponding qj is at most this quantity; every argument below still works.
Writing M=E_eta G²/qprev, we have qj/qprev<=M. Since

    M-1-log(qj/qprev) >= M-1-log M >=0,

data processing gives

    ej >= D(eta_j || N(0,qprev)) >=0.                    (2)

Thus the critical scalar Bellman inequality and dissipation apply with costs
ej, even though the actual vector prior has prefactor t:

    ej >= V(qprev)-V(qj),
    ej >= qj-qprev+c qprev².

The second bound is needed only when qprev<=1. Its universal constant can
also be extended to qprev<=2 by the same compactness argument; alternatively
discard the first transition in occupation counts and bound it separately.
The actual readout satisfies r1>=1/(8qH)>=V(qH). Therefore

    sum_{j<=i} ej <= Atilde-V(qi) <= epsilon+C0 qi,
    sum_j ej <= V*+epsilon.                              (3)

All variances are positive, because a zero variance propagates at finite
entropy and cannot produce the stipulated nonzero output.

For the advertised action-only bound, use q0<=2 and r1>=1/(8qH):

    (1/2)log(qH/q0)+r1
       >= (1/2)log(qH/2)+1/(8qH) >= -1.

The infimum is attained at qH=1/4 if one optimizes the right side, so the
loose constant one is valid. Substitution gives Atilde<=A-Hc_t+a.

## One-step gain is at most sqrt(ej)

Write u=log(qj/qprev), g=log[t sqrt(R(Dj))]. When u>0, (2) and Gaussian
second-moment entropy duality give

    ej >= (exp(u)-1-u)/2 >= u²/4.

Hence always u<=2sqrt(ej). The exact inverse relation for g is

    Dj-c_t = a g +(1+a)/2 [exp(2g)-1-2g].                 (4)

If g>=0, the right side is at least a g+(1+a)g². But the definition of ej
also gives Dj-c_t=a u/2+ej<=a sqrt(ej)+ej. Were g>sqrt(ej), these two
inequalities would contradict each other. Thus

    g <= sqrt(ej).                                      (5)

The conclusion is immediate when g<0. Summing (5) and applying the existing
critical square-root entropy occupation lemma to (2)-(3) yields

    sum g <= C log(H+2)+C sqrt(H epsilon).                (6)

This step subtracts the scalar terminal baseline rather than applying Jensen
to the raw action A, which would leave a spurious contribution from V*.

## A complementary linear-excess gain bound

For a>0, the nonnegative exponential remainder in (4) gives the tangent bound

    g <= u/2+ej/a.                                      (7)

Summing over any consecutive prefix telescopes u. Because q0>=1 and qH<=1,
the whole-path version is

    sum g <= (sum ej)/a <= (V*+epsilon)/a.                (8)

If epsilon>=1/4, (8) is O(epsilon/a). If a>=1/4, it is O(1+epsilon/a).
It remains to consider 0<a<1/4 and 0<=epsilon<1/4, so sum ej<3.

Let m=min_i qi. If m>=1/4, the usual occupation estimate makes H universally
bounded and the desired bound is immediate. Otherwise put b=max(a,m)<1/4,
u_j=2^j b, and let J be the least index with u_J>=1/4. Define last-exit
indices tau_j=max{i:qi<=u_j}. They exist and are nondecreasing.

For the initial prefix through tau_0 there are two cases.

* If m<=a, then b=a, q_tau0<=a, and (7), (3) imply

      sum_{j<=tau0} g_j
         <= (1/2)log(q_tau0/q0)+(epsilon+C0 a)/a
         <= C0+epsilon/a.

* If m>a, then b=m. All states in that prefix are at least m and its entropy
  is at most epsilon+C0 m. The occupation inequality bounds its length by
  C(epsilon/m²+1/m). Cauchy-Schwarz and (5) bound its gain by
  C(1+epsilon/m)<=C(1+epsilon/a).

For a nonempty block (tau_j,tau_{j+1}], remove the first transition. Every
remaining pre-state exceeds u_j and its endpoint lies in (u_j,2u_j]. Its
entropy is at most epsilon+2C0 u_j by (3). The occupation estimate bounds
its length, with the first transition restored, by

    C(epsilon/u_j²+1/u_j).

Cauchy-Schwarz and (5) therefore bound its entire gain by

    C(1+epsilon/u_j).

The tail after tau_J has bounded length and bounded gain, again after
removing at most its first transition. Summing the geometric series gives

    sum g <= C[1+log(1/a)]+C epsilon/a.                  (9)

When a>=1/H, log(1/a)<=log H, so (9) and (6) prove (1). When a<1/H, use (6).
If epsilon>=a²H, the smaller term in (1) is sqrt(H epsilon). If instead
epsilon<a²H, then sqrt(H epsilon)<aH<1, so (6) is already O(log(H+2)); this
also proves (1). The case H=1 is absorbed by the same universal constants.

## Why the interpolation matches a plausible uniform target cost

Suppose a target construction supplies, with S>=1+log(H+2),

    A <= Hc_t+V*+C[a S+S²/H],

and the one-input adjusted action is used. Its effective epsilon is at most
C'[a S+S²/H], since the extra +a is absorbed by aS. If a>=S/H, then

    epsilon/a <= C'[S+S²/(aH)] <= 2C'S.

If a<=S/H, then sqrt(H epsilon)<=C''S. Hence (1) gives total gain O(S),
including the logarithmic factor, uniformly as t approaches one. Coupled
with normalized importance compression and the logarithmic-tolerance
finite-width certificate, this is the needed capacity estimate for such
target masses. It does not establish those masses by itself.

