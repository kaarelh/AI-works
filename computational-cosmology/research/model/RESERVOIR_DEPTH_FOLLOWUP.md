# Reservoir size and sequential depth: follow-up audit

8 October 2026. Independent theory check of the objection that a universe-scale fuel inventory is already near its Schwarzschild scale and therefore cannot simply be compressed into one fast computer. No changes to the report were made in this follow-up.

## Assessment

The objection identifies a real constraint on **instantaneous concentration, coherent working memory, and completion time**. It does not, by itself, impose a finite lifetime sequential-depth bound in a spacetime with unlimited proper future. The report's strongest justified conclusion is narrower than “a substantial part of cosmic negentropy can be spent on a very deep sequential computation”:

> A processor's lifetime fuel inventory need not all participate in each dependent operation. An extended, retained reservoir can in principle be supplied to a smaller core over time, so the reservoir's light-crossing time need not be the core's clock period. This removes one proposed obstruction; it does not establish a large attainable serial depth, a capture fraction, or an indefinitely reliable architecture.

The opening's “reasonably clear answer” and section 4's “conditional positive answer” can sound more conclusive than this. Acknowledge that large retained masses cannot be arbitrarily compressed and that gathering an order-unity fraction of the entire one-way reachable matter is a more demanding claim than the report's lossy baryonic photon-return benchmark.

## 1. The strongest straightforward finite-deadline constraint

Consider a spherical, approximately stationary computer whose every sequential layer must propagate information over its full working radius R. In a weak-field/common-clock approximation, its number of such layers by a deadline T is bounded by

\[
D_{\rm global}(T)\lesssim cT/R.
\]

Noncollapse requires a radius larger than the mass's gravitational radius. Thus a schematic combined scale is

\[
D_{\rm global}(T)\lesssim {c^3T\over2GM},
\]

provided the mass M really is part of the working system that each layer must span. Close to black-hole or cosmological horizons, replace this estimate by the actual null propagation time and specified observer clock; it is not a generally covariant inequality in this form.

For M of cosmic scale c^3/(GH), the minimum global communication scale is of order H^-1. In one Hubble time, such a machine obtains only order-unity whole-system rounds. It may perform an enormous number of local operations in parallel during one round. This is the strongest clean version of the user's intuition: an aggregate cosmic operation count is not a comparable number of sequential globally integrated operations.

The report's memory comparison gives the related conditional scale tau_global ~ t_P sqrt(B), up to constants. A program requiring all B bits to communicate every layer is much more constrained than a program with B bits of total archive but a small active working set.

## 2. What a supplied small core changes

Let r(t) be useful sequential steps per unit proper time, tau_core the architecture's minimum step time, B_del(t) cumulative usable entropy capacity delivered to the core, and h>0 its entropy consumption per useful step. A simple fluid accounting gives

\[
r(t)\le1/\tau_{\rm core},\qquad
hD(t)\le B_0+B_{\rm del}(t).
\]

These are rate and cumulative-resource constraints, not a requirement to send a query to the reservoir on every step. Fuel delivery can be scheduled, buffered and pipelined. It nevertheless has to occur causally and with sufficient power, purity and reliability. The core also needs somewhere to put entropy, and its active working state must remain protected.

A distant reservoir can therefore increase total lifetime steps without proportionally increasing the core's latency, just as a larger fuel tank need not slow an engine's cycle. It does not make a deadline disappear. Any calculation using a specified distant resource must last long enough for the resource or its usable output to arrive, and enough cumulative resource must be available at every prefix of the calculation.

With a finite lifetime T, even a perfectly retained fuel supply may contain far more potential work than one core can use by T. With genuinely unlimited proper future, rate bounds alone allow unbounded cumulative steps. That mathematical statement does not prove survival, negligible dissipation, infinite usable fuel, or attainable reliable depth.

## 3. Planck-rate comparison: useful scale, not a universal theorem

A common heuristic combines an orthogonalizing operation time hbar/E with a light-crossing/collapse time GE/c^5. Optimizing their maximum gives an order-t_P minimum step time. More explicitly, tau >= pi hbar/(2E) and tau >= 2GE/c^5 give tau >= sqrt(pi)t_P.

This argument has strong premises: the relevant operation really must orthogonalize, the interaction energy and its gravitational effect are counted consistently, the region must communicate as assumed, and semiclassical reasoning is extrapolated to Planck scales. It is not a proven universal clock-rate bound for arbitrary quantum algorithms. Jordan's counterexamples to energy-only computational speed bounds are directly relevant. [Jordan 2017](https://arxiv.org/abs/1701.01175)

Nevertheless, **even granting one useful sequential step per Planck time** gives a useful illustration:

- t_P = 5.39125×10^-44 seconds.
- For H_Lambda = 1.808×10^-18 s^-1, one asymptotic Hubble time is 1.75266×10^10 years and contains 1.02592×10^61 Planck times.
- A chain of 10^120 such steps lasts 1.70838×10^69 years.

Thus “10^120 total operations” must not be read as “10^120 sequential steps on anything resembling a cosmological timescale.” The future-time qualification does crucial work.

Related clock–lifetime tradeoffs exist in the literature, but do not casually apply them to a core supplied, repaired and replaced from an extended reserve. Ng's bound explicitly concerns a “simple” clock/computer; assembled clock sequences are an exception discussed in that work. Foundational distance-measurement versions have also been debated. [Ng 2001](https://arxiv.org/abs/gr-qc/0006105), [Baez & Olson 2002](https://arxiv.org/abs/gr-qc/0201030), [Ng & van Dam response](https://arxiv.org/abs/gr-qc/0209021).

## 4. Independent black-hole lifetime calculation

Use the report's collected-energy-equivalent mass M0 = 3.12×10^50 kg. In the neutral nonrotating blackbody evaporation approximation,

\[
r_s=2GM/c^2,\quad
\tau_{\rm lc}(M)=r_s/c=2GM/c^3,
\]

\[
{dM\over dt}=-{\alpha\over M^2},\qquad
\alpha={\hbar c^4\over15360\pi G^2},\qquad
t_{\rm life}={M_0^3\over3\alpha}.
\]

Independent evaluation with G=6.67430×10^-11 SI, c=299792458 m/s, and hbar=1.054571817×10^-34 J s gives:

| Quantity | Value |
|---|---:|
| Initial radius-crossing time | 4.89806×10^7 years |
| Textbook evaporation lifetime | 8.09528×10^127 years |
| Lifetime / initial crossing time | 1.65275×10^120 |
| Initial Bekenstein–Hawking entropy | 3.72565×10^117 bits |
| Integrated shrinking-radius intervals | 2.47913×10^120 |

The last row follows by integrating rather than holding the initial radius fixed:

\[
N_{\rm lc}=\int_0^{t_{\rm life}}{dt\over\tau_{\rm lc}(M(t))}
={c^3M_0^2\over4G\alpha}
={3840\pi GM_0^2\over\hbar c}
={3\over2}{t_{\rm life}\over\tau_{\rm lc}(M_0)}.
\]

This is a count of nominal geometric intervals, not a count of programmable black-hole gates or a guaranteed circuit depth. A diameter-crossing convention changes the factor two. Greybody factors and particle species change the evaporation coefficient. Gravitational time and the placement of the observing clock matter. The negligible final Planck-mass interval cannot make a controlled semiclassical computation out of the entire lifetime.

The more conservative use of the calculation is as a storage-longevity illustration: if a small external core were to perform 10^120 dependent steps during that lifetime, its **average** allowed step duration would be approximately **8.1×10^7 years**. The assumed storage timescale is therefore not obviously too short merely because the required number of steps is enormous. Efficiently collecting Hawking radiation, preserving an external processor, disposing of entropy, and managing the final high-power phase are still outstanding construction problems.

For comparison, this mass's ideal de Sitter erasure-equivalent budget is 1.33314×10^120. Its similarity to the integrated interval count is not universal. Their ratio is

\[
{N_{\rm lc}\over B_{\rm erase}}=1920\ln2\,{GMH_\Lambda\over c^3},
\]

which is about 1.86 for this chosen mass and changes linearly with M. Do not treat that numerical coincidence as a derived universal sequential budget.

[Hawking's calculation](https://doi.org/10.1007/BF02345020) supplies the underlying evaporation physics. The report already lists important idealizations; this follow-up does not strengthen the evaporation model's status.

## Answer to the objection

The user's intuition is right for a **fast computation using most cosmic matter as an actively communicating whole**. Black-hole avoidance prevents arbitrary concentration; cosmological binding places a competing outer scale; finite deadlines sharply limit global sequential rounds. The supplied-core distinction does not refute those constraints. It instead describes a different kind of computation: small instantaneous working state, slowly consumed resources, and potentially extraordinarily long duration.

The correct answer remains conditional: this architecture evades the simple inference that every step must take a reservoir light-crossing time, but no rigorous positive lower bound near 10^120 useful reliable sequential steps has been established here. A report should identify both the genuine finite-deadline obstruction and the unresolved long-duration construction problem.
