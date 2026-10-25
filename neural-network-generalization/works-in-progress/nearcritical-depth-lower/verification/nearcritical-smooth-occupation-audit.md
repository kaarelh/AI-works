# Smooth scalar occupation: a dimension-free action bound

25 October 2026. Independent check of the smooth-potential idea proposed in the normalized near-critical coupling thread. This is a deterministic lemma conditional on the indicated scalar empirical-quality estimate. It does not by itself prove a new posterior theorem.

Let `T_e(q)=E tanh^2((1+e)sqrt(q)Z)`, with `0<=e<=e0`, and suppose `0<q_j<=2`. Assume that for quality `v_j<=v0`,

`q_(j+1) <= T_e(q_j) exp(K sqrt(v_j))`.                  (1)

For large quality only the cap `q_(j+1)<=2` is needed. A bound with `K(sqrt(v)+v)` is equivalent after reducing the fixed v0. Fix a sufficiently large absolute b. There are uniform constants such that

`sum_j q_j^2 1{q_j>=2b e} <= C(q_0+sum_j v_j)`.          (2)

At e=0 the indicator means every positive q_j, and (2) remains valid. The same conclusion applies to the maximum variance over arbitrarily many coordinates and two coupled states, because T_e is increasing and (1) can be taken uniformly over all of them. No sum over input coordinates is introduced.

## Free scalar drift

For q>=b e, the expansion near zero and compactness away from zero give

`q-T_e(q)>=c q^2`.

Indeed `T_e(q)=q+O(e q)-2q^2+O(e q^2+q^3)`, so choosing b large absorbs the positive e q term for small q. At e=0, `E tanh^2(sqrt(q)Z)<q` for every q>0; compactness supplies the remaining uniform bound, and sufficiently small e0 preserves it. Also `T_e(q)>=.75q` on a fixed small-q interval, and `T_e(q)` is uniformly bounded below on a fixed interval away from zero.

For e>0 put a=b e and define the nonnegative increasing potential

`V(q)=0` for q<=a,

`V(q)=q-a-a log(q/a)` for q>a.

Thus `V'(q)=(1-a/q)_+` and `0<=V(q)<=q`. For q>=2a, the free integration interval from T_e(q) to q stays a fixed relative distance above a: use `T_e(q)>=.75q` at small q and the compact lower bound away from zero. Consequently

`V(T_e(q))-V(q)<=-c q^2` for q>=2a.                    (3)

In the band a<q<2a, write `u=T_e(q)` and `delta=(u-a)_+`. If u>a, integration gives

`V(q)-V(u) >= (delta/q)(q-u) >= c e delta`.             (4)

If u<=a, V(u)=0. It would be incorrect to replace delta in (4) by q-a uniformly: the free step can cross the barrier, and the potential is quadratic arbitrarily close to that barrier.

## Adding relative noise

In logarithmic coordinates, `U(s)=V(exp(s))` has

`U'(s)=(exp(s)-a)_+`,  `U''(s)=exp(s)1{exp(s)>a}`

away from the single harmless second-derivative jump. Taylor's integral remainder and (1), with h=K sqrt(v), give

`V(q_next) <= V(u)+(u-a)_+ h+C u v`,  u=T_e(q),          (5)

uniformly for v<=v0. If q<=a, monotonicity and T_e(a)<a imply u<=a, so only the O(e v) remainder remains. In the band a<q<2a, the linear term in (5) is delta K sqrt(v); Young's inequality gives

`delta K sqrt(v) <= (c e/2)delta+C(delta/e)v <= (c e/2)delta+C v`,

because delta<=a=b e. Combine this with (4), or use the zero-linear-term case when u<=a. Above q>=2a, the linear term is at most C q sqrt(v), which is absorbed by half the drift (3) plus C v. The remainder C u v is also O(v).

Thus for all q and small quality,

`V(q_next)-V(q) <= -c q^2 1{q>=2a}+C v`.               (6)

For v>=v0 the same inequality follows by increasing C, since q and q_next are capped by 2 and 0<=V<=q. Telescoping proves (2).

At e=0, simply take V(q)=q. The free drift is c q^2 and (5) becomes a C q sqrt(v)+C qv perturbation, absorbed by the same Young inequality. This avoids division by e and proves the endpoint separately.

## What this audits and what it does not

The compact-range population coupling bound in `nearcritical-normalized-coupling.md` has logarithmic gain C q_max^2. Equation (2) controls its contribution on variance excursions by C(1+total quality), without charging a constant for each excursion step. The remaining near-critical variances are O(e), and their per-step population gain is O(e^2). The correlation/spectral occupation, local contraction, empirical uniformity, and posterior rare-event budget remain separate ingredients.

At e=0 this supplies an occupation estimate but no contraction toward a white covariance. In particular it does not evade the critical correlation-memory obstruction or establish the requested unrestricted-depth learning theorem.
