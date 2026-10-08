# Retaining a cosmic fuel reserve: collapse, expansion, depletion, and depth

Follow-up to the user's challenge to section 4. This is a quantitative audit and an ideal mechanical counterexample, not a demonstrated durable architecture. The main report has not been edited in this follow-up. Numbers use the same eternal, flat Lambda-CDM reference model as the report. Machine-readable results are in `retention_results.json`.

## What changes after taking the objection seriously

The objection identifies a real constraint: separating fuel from a processor does not make the fuel's gravity or cosmological loss disappear. All fuel retained in one permanent system must occupy a suitable self-gravitating configuration; moreover, burning it changes that configuration. A simple claim that its radius falls between the Schwarzschild and turnaround radii is not a stability or longevity proof.

However, the objection does not by itself imply that the reserve's light-crossing time is the core's clock period, or that the reserve must disappear after one Hubble time. The important quantitative distinctions are (i) one-way accessible initial matter versus centrally returnable energy, (ii) total static mass versus orbital stability, (iii) a central anchoring mass that is burned versus a self-gravitating reserve consumed from outside inward, and (iv) an expansion-imposed lifetime versus other physical failure mechanisms.

## 1. The strongest simple spherical mass check

For a spherical isolated system with a Schwarzschild-de Sitter exterior,

\[
f(r)=1-\frac{2GM}{c^2r}-\frac{H_\Lambda^2r^2}{c^2},\qquad
r_{\rm ta}=(GM/H_\Lambda^2)^{1/3}.
\]

The maximum of this exterior metric function occurs at the turnaround radius. Writing

\[
M_N=\frac{c^3}{3\sqrt3GH_\Lambda}=4.298\times10^{52}\ {\rm kg},
\]

gives the particularly useful exact result

\[
f(r_{\rm ta})=1-(M/M_N)^{2/3}.
\]

Thus a nondegenerate static exterior interval requires **gravitational mass parameter** \(M<M_N\). Checking only \(r_s<r_{\rm ta}\) misses this stronger condition near the cosmological scale. At the Nariai limit, both exterior horizons have radius 10.12 Gly, while the naive Schwarzschild radius is only 6.747 Gly. The cosmological term matters substantially there.

The initial matter inside the present event horizon has rest-mass equivalent close to this threshold. But the original expanding FLRW region is not an isolated static object, and is not thereby already a black hole. Nor can one identify its initial rest mass exactly with the gravitational mass of an assembled system: binding energy and energy radiated during assembly matter. A few-percent energy loss can change whether the first row below is above or below the threshold. The table is a diagnostic comparison, not a proof that all such matter can or cannot be gathered.

| Initial resource or received energy equivalent | Mass (kg) | \(M/M_N\) | \(r_s\) (Gly) | \(r_{\rm ta}\) (Gly) | \(f_{\max}\) |
|---|---:|---:|---:|---:|---:|
| One-way accessible, all matter | \(4.424\times10^{52}\) | 1.0293 | 6.945 | 10.219 | −0.0195 |
| One-way accessible, baryons | \(6.924\times10^{51}\) | 0.16110 | 1.087 | 5.507 | 0.7039 |
| Light-speed return region, all matter | \(5.530\times10^{51}\) | 0.12867 | 0.8681 | 5.109 | 0.7451 |
| Light-speed return region, baryons | \(8.655\times10^{50}\) | 0.02014 | 0.1359 | 2.753 | 0.9260 |
| Photon-return protocol, all-matter energy equivalent | \(1.991\times10^{51}\) | 0.04633 | 0.3126 | 3.635 | 0.8710 |
| Photon-return protocol, baryonic energy equivalent | \(3.116\times10^{50}\) | 0.00725 | 0.04892 | 1.959 | 0.9625 |

Here one-way accessibility uses the 16.679 Gly present event horizon; the light-speed return region has half that radius and one eighth its initially comoving matter. Return-region mass is not a delivery guarantee. Photon-return rows include cosmological redshift and the idealizations already stated in the report; they are received energy divided by \(c^2\), not actual constructed matter reserves. Conversion, recoil, capture, entropy, and preservation remain additional requirements. The table does not count the same energy as both fuel and a separate clean-memory resource.

For the report's baryonic photon-return benchmark, the exact SdS black-hole horizon is 0.0489210 Gly and the exterior cosmological horizon is 17.5050 Gly. A radius of 0.9794 Gly has

\[
\frac{2GM}{Rc^2}=0.04995,\qquad
\frac{H_\Lambda^2R^2}{c^2}=0.003122,\qquad f(R)=0.94693.
\]

This is well away from either exterior horizon. The one-way all-matter comparison is cosmologically marginal; the actual baryonic return benchmark is not.

## 2. Passive circular-orbit storage has a stronger bound

An exterior static interval is not enough to obtain stable freely orbiting test particles around a central spherical mass. [Nolan (2014), Proposition 11 and Appendix B](https://arxiv.org/abs/1408.0044), establishes the SdS condition

\[
\frac{GMH_\Lambda}{c^3}<\frac{2}{75\sqrt3}
\quad\Longleftrightarrow\quad M<0.08M_N=3.438\times10^{51}\ {\rm kg}.
\]

At equality the innermost and outermost stable circular orbits coalesce. Thus the one-way baryonic mass and return-region all-matter mass, if used as central gravitational mass parameters, are below Nariai but above this orbital threshold. Both photon-return energy equivalents are below it.

This is a restriction on **exterior circular timelike geodesics around a central mass**, not a universal bound on pressure-supported, extended, actively controlled, or nonspherical reserves. Nolan also proves the existence of future-complete bound geodesics in appropriate asymptotically de Sitter McVittie backgrounds. Such results refute an automatic expansion deadline for ideal bound trajectories; they do not prove indefinitely reliable machines or interacting finite-particle reservoirs.

## 3. Burning the anchoring mass can release the remaining fuel

For a Newtonian test orbit around a central mass, including a positive cosmological constant,

\[
j^2=GMR-H_\Lambda^2R^4.
\]

Radial stability requires \(R<r_{\rm ta}/4^{1/3}\). If the central mass is slowly radiated away without exerting a torque on the orbit, specific angular momentum \(j\) remains fixed and the orbit expands. The allowed turnaround scale simultaneously shrinks. This is a genuine depletion instability omitted by a static radius comparison.

For an initially stable orbit at \(R_0=f r_{{\rm ta},0}\), the mass at which its stable and unstable circular solutions merge is

\[
\frac{M_{\rm crit}}{M_0}
=\frac{4}{3^{3/4}}[f(1-f^3)]^{3/4}.
\]

Derivation: the maximum of \(GMR-H^2R^4\) occurs at \(R=(GM/4H^2)^{1/3}\); its value is \(3H^2R^4\). Equate this to the initial angular momentum squared. For initial \(f=0.5,0.1,0.01\), the remaining central-mass fractions at the loss of stability are respectively **0.944, 0.312, and 0.0555**. A test reserve initially at half turnaround can therefore lose its passive circular equilibrium after only about 6% of its central anchor is consumed. These are Newtonian examples for a central-mass/test-fuel architecture, not bounds on every self-gravitating reserve. Relativistic effects give additional restrictions when compactness is appreciable.

## 4. Outside-in consumption is a useful, limited counterexample

An ideal spherical, collisionless ensemble of circular orbits provides a different force-balance model. Random orbital planes yield a spherical mean density and no preferred net angular momentum. Such systems are called Einstein clusters. [Böhmer & Harko (2007)](https://arxiv.org/abs/0705.1756) construct the model including a cosmological constant. Their stability analysis neglects Lambda, so it should **not** be cited as a stability proof for the example here.

In the Newtonian mean-field limit, choose a constant density \(\rho\), so

\[
M(<r)=\frac{4\pi\rho r^3}{3},\qquad
v^2(r)=\left(\frac{4\pi G\rho}{3}-H_\Lambda^2\right)r^2.
\]

Now remove and consume the **outermost** fuel shells first. By the spherical shell theorem, removing an exterior shell leaves the force on every still-unconsumed interior shell unchanged. Each remaining shell retains its original enclosed mass and orbital force until it is itself consumed. At the receding boundary,

\[
R\propto M^{1/3},\qquad
R/r_{\rm ta}=\text{constant},\qquad
2GM/(Rc^2)\propto M^{2/3}.
\]

The remaining configuration therefore stays at the same fraction of turnaround while becoming less compact. This avoids the particular problem of destroying a central anchor while leaving outer fuel in place. It is only an ideal quasistatic mechanical consistency argument. Interior metric time normalization changes as shells are removed in a relativistic treatment, even though the corresponding spherical exterior-shell force argument remains useful.

For the baryonic photon-return mass, choosing \(R=0.5r_{\rm ta}=0.9794\) Gly corresponds to mean density \(9.35\times10^{-26}\) kg/m³, sixteen times the dark-energy mass density. The boundary's Newtonian orbital speed is \(0.148c\), its dynamical time \(R/v\) is 6.63 Gyr, and its orbital period is 41.6 Gyr. This is an illustrative mildly relativistic configuration, not a rigorously constructed solution at finite particle number.

Sending shell energy inward and waste energy outward perturbs the interior. For power \(P\), one beam crossing a reserve of radius \(R\) has in-flight mass of order

\[
M_{\rm flight}\sim\frac{PR}{c^3}.
\]

For this example it is small relative to the reserve when \(P\ll9.1\times10^{50}\) W; both inward and outward flows change the order-one coefficient. Slow consumption helps this quasistatic condition. A small central core separately requires that absorbed energy does not accumulate faster than it can be used and expelled. Neither stream needs a round-trip message reporting every intermediate computational state to the reservoir.

Nothing here establishes storage for arbitrary physical durations. Finite-particle relaxation, collisions, radiation, particle decay, orbit perturbations, control errors, thermal noise, and maintaining the processor's own state could defeat the architecture. Conversion of the received photons into the assumed suitable reserve is also unproved. The counterexample has a narrower role: **collapse and cosmic expansion alone do not yield a universal lifetime or small-sequential-depth theorem from the total fuel mass.**

## 5. What the large size really does imply about depth

At \(R=0.9794\) Gly, a radius-crossing dependency takes about 0.9794 Gyr in the weak-field approximation. There are only about **18 such radius crossings per asymptotic Hubble time**, or about 9 diameter crossings. Thus a computation that globally synchronizes the full reserve after each operation has extremely low sequential depth per Hubble time. That part of the user's intuition is quantitatively right.

But \(H_\Lambda^{-1}=17.53\) Gyr is an expansion timescale, not an expiration time for a bound system. If a suitable bound configuration lasts \(T\), its number of global rounds is of order \(cT/R\), while a pipelined small core need not take a global round per instruction. To turn retention into a total-depth bound requires an additional lifetime, maintenance, thermal, or information-storage argument. The report should not imply those arguments have already been settled positively.

**Status:** Nariai and the exterior circular-orbit threshold are established under their stated spacetime assumptions. The numerical comparisons and central-anchor depletion formula are direct calculations. Outside-in consumption is a new ideal quasistatic force-balance counterexample, explicitly not a stable indefinitely durable implementation. No general achievable cosmic sequential-depth bound has been derived here.
