# Joint Gaussian growth and purification remove the scalar holding logarithm

26 October 2026. Critical tanh variational action. This improves a target-path construction; it is not a new unrestricted posterior sample theorem.

## 1. A suffix lemma

Suppose a finite-query covariance has

    Q=p ff^T+R,     R>=0,     diag R=r<=p,

where f is Boolean, R has the CONSTANT diagonal value r<=p, and 0<p<=p0 for a sufficiently small universal p0. There is a continuation of length at most C/p, producing margin1/2 on f, whose total hidden plus readout action is at most

    V_*+C p.                                         (1)

The continuation uses Gaussian target-component inflation until the target variance is of order sqrt(p), then an unrestricted nearoptimal scalar suffix. No separate fixed-variance purification interval is needed.

We use the published expansion

    V(a)=V_*−2a+O(a²)

from critical-depth/source/unrestricted-critical-scalar-expansion.tex. This is stronger than the older coarse bridge estimate. We also use the existing short increasing scalar-path and small-residual lifting lemmas.

## 2. Uniform one-step estimates and a prescribed sequence

At current tracked component v and residual diagonal r, put q=v+r. For a target Gaussian inflation 1+eta with eta=O(q), write u=(1+eta)v and Qpre=u+r. The full conditional-mean component and the residual satisfy, uniformly for q small,

    v'=u[1−2Qpre+O(Qpre²)]
       =v[1+eta−2q+O(q²)],                           (2)
    r'<=r[1−2Qpre+O(Qpre²)]
       <=r[1−2q+O(q²)].                              (3)

A rigorous uniform derivation of (2) uses the Gaussian Hermite expansion. The covariance of two tanh variables of variance Qpre sharing a Gaussian component of variance u has first-chaos contribution u[E sech²(sqrt(Qpre)Z)]², with E sech²=1−Qpre+O(Qpre²). The third-and-higher covariance is at most C u³<=C u Qpre², since the corresponding variance is O(Qpre³) and its correlation factor is at most (u/Qpre)^3. For (3), conditional Gaussian Poincare gives r'<=r E sech^4(sqrt(Qpre)Z), whose expansion is r[1−2Qpre+O(Qpre²)]. All constants are uniform in v/r.

Set a=sqrt(p), and prescribe in advance the exact sequence

    v_next=min{a, v+2v²},       v_initial=p.          (4)

At zero inflation the full conditional-mean component is at most v. By continuity and (2), an inflation eta in [0,Cq] realizes every step in (4) exactly. For every full step, solving (2) gives

    eta=4v+2r+O(q²).

The scalar Gaussian entropy charge then satisfies

    D<=.5[eta−log(1+eta)]
      <=4v²+4vr+r²+Cq³.                              (5)

At the last shortened step it is enough to use D<=Cq². This fixed component sequence, including its number of steps, does not depend on the residual or an earlier holding interval.

The residual is nonincreasing for sufficiently small q. On full steps, (3) and (4) give

    v_next r_next<=v r exp(Cq²).                     (6)

The same bound holds at the shortened step because its component increment is smaller.

## 3. Cost and residual at the end of prescribed growth

Since r never exceeds p and v>=p, q<=2v. The sequence (4) has length at most C/p and

    sum q²<=Ca.

Indeed q²<=4v²=2(v_next−v) on each full step, and the final shortened step costs O(a²) in this sum. Iterating (6) yields

    v r<=C p²,       r<=C p²/v.                      (7)

For full steps dv=v_next−v=2v². Equation (5) becomes

    D<=2dv+2(r/v)dv+[r²/(2v²)]dv+C(q³/v²)dv.        (8)

Here q³/v²<=8v. Consecutive component ratios are uniformly bounded, so discrete integration and (7) give

    sum (r/v)dv<=Cp² integral_p^a v^(−2)dv<=Cp,
    sum (r²/v²)dv<=Cp⁴ integral_p^a v^(−4)dv<=Cp,
    sum v dv<=Ca².

The shortened final step has entropy O(a²). Therefore

    sum D<=2a+C(p+a²)=2a+Cp,
    r_end<=C p²/a.                                  (9)

The covariance decomposition and exact full-conditional-mean score are retained throughout; no residual is silently discarded.

## 4. Append a short accurate scalar suffix

Choose an increasing scalar path from a with total cost at most V(a)+p. Such a path exists by the increasing-path reduction and arbitrarily close approximation of the infimum.

Since p<=a, this path also satisfies the published short-path hypothesis cost<=V(a)+a. Hence its length is at most C/a. Lift it with residual r_end using the critical small-residual lifting lemma. Its extra readout action is at most

    C r_end/a <=C p²/a²=C p.                (10)

The scalar value expansion gives

    V(a)+p <=V_*−2a+C a²+p
           <=V_*−2a+C p.

Combining this with (9) and (10) proves (1). Total length is O(1/p). A strict margin follows by an arbitrarily small readout inflation.

The square-root entropy sum of this suffix is O(log(2/p)): during Gaussian growth, sqrt(D)<=Cq<=C v and v=(v_next−v)/(2v) on full steps, while the appended scalar path has the existing logarithmic bound.

## 5. Consequence for the unmodified Gaussian target seed

Let Q_1 be the first unmodified tanh covariance on the full cube, and define

    a_f=(f^T Q_1^(-1) f)^(-1),
    S_f=1+log(1/a_f).

The established free-cooling/target-component lemma retains a component at least c Delta a_f at a layer with diagonal at most Delta, after O(1/Delta) free layers. Reducing the tracked component to Delta exp(−C S_f) is harmless.

For H>=C S_f, choose Delta=B S_f/H, with B a sufficiently large universal constant; assume this is in the small-variance range by increasing the depth threshold. Hold the weak component as necessary and then use prescribed Gaussian growth to reach component p=Delta, keeping residual at most Delta.

The entire prefix has entropy

    O(H Delta²+S_f Delta+Delta)=O(S_f²/H)

and takes fewer than H−C/Delta layers after B is chosen large. The suffix lemma above then reaches the final margin with additional action V_*+C Delta and at most C/Delta layers. Fill the exact available depth by holding the weak component before growth, as in the existing target-seed construction.

Consequently the critical variational target rate obeys the sharpened upper bound

    J_(H+1)(f) <= V_*+C S_f²/H,    H>=C S_f.          (11)

This removes the previous additive log²(H)/H from that unmodified-seed variational upper. It does not assert a new finite-width target-mass estimate without separately checking bounded-score and finite-channel resources. It also does not show S_f is logarithmic in arbitrary deep teacher complexity. Those remain distinct issues.

Together with the established inverse-depth lower bound J_(H+1)(f)>=V_*−C/H, (11) gives J_(H+1)(f)=V_*+O_f(1/H) for every fixed Boolean target. The first-kernel spectral estimate gives S_f<=C(d+1), so the upper is also uniformly V_*+C(d+1)²/H over all Boolean targets when H>=C(d+1).

## Source interfaces

All imported sources are in neural-network-generalization/works-in-progress/critical-depth/source:

- critical-rate-foundations.tex: lem:critical-cheap-holding, eq:critical-component-growth, lem:critical-scalar-lift;
- critical-scalar-paths.tex: lem:critical-dyadic-short-path;
- unrestricted-critical-scalar-expansion.tex: thm:critical-scalar-expansion;
- critical-target-seed-upper.tex: unmodified first-kernel seed and free-cooling construction.

The appended scalar suffix has length O(1/a) even though its chosen error tolerance is p rather than a: the stronger tolerance automatically meets the original weaker nearoptimality hypothesis. The preceding prescribed Gaussian component sequence has length O(1/p), independent of the residual, which makes exact-depth padding before that sequence legitimate.

