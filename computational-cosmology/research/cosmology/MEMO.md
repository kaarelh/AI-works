# Cosmological access, collection, and sequential computation

Research memo for the computational-cosmology report. Prepared 8 October 2026. This is a contribution to the report, not its final text. Numerical results and assumptions are reproduced by `calculate_access.py` and recorded in `access_results.json`.

## Main conclusions

1. The right object for an answer that returns to one observer is a **causal diamond**, not the presently observable universe. Future descendants whose experiences matter in their own right can use a larger region than a computer whose answer must come back here.
2. A cosmological horizon does **not** force an already gravitationally bound computer to expand. For a large range of masses there is substantial room between gravitational collapse and failure to remain bound. It is unnecessary to put all future fuel beside the active processor at once.
3. Expansion therefore does not, by itself, rule out spending an appreciable collected resource on a long sequential computation. A compact processor can draw down a spatially extended bound reserve. The serious unresolved constraints become reliable memory, conversion of fuel into work, entropy disposal, and survival of the apparatus over the desired depth.
4. Under eternal positive cosmological constant, task launch and resource acquisition have deadlines, whereas a bound laboratory can have arbitrarily long proper time. The universe is a system with finite remaining communication distance, not a system with a single finite wall-clock deadline.
5. An explicitly specified, extraordinarily optimistic photon-return protocol produces approximately $1.3\times10^{120}$ *irreversible bit erasures* from baryons at the asymptotic de Sitter temperature. This is not a bound on reversible logical operations and is not an engineering feasibility result.
6. The geometric window for launching probes is billions of years, not centuries. Near-term research can be worthwhile even when it delays expansion slightly. Later algorithms can often catch earlier, slower probes. Extremely fast expansion reduces that opportunity.

## 1. Empirical cosmology and the conditional baseline

All numerical statements below assume a spatially flat, eternally expanding $\Lambda$CDM future. Adopt $H_0=67.4$ km s$^{-1}$ Mpc$^{-1}$, $\Omega_m=0.315$, $\Omega_b=0.0493$, $\Omega_r=9.2\times10^{-5}$, and $\Omega_\Lambda=1-\Omega_m-\Omega_r$. These are rounded Planck-like fiducials, not a new fit. The resulting asymptotic expansion rate is $H_\Lambda=H_0\sqrt{\Omega_\Lambda}=1.808\times10^{-18}$ s$^{-1}$. [Planck 2018 cosmological parameters](https://arxiv.org/abs/1807.06209).

The positive constant is an extrapolation. The July 2026 DESI DR2 Lyman-alpha analysis reports preferences for a two-parameter evolving dark-energy model of $2.7\sigma$ with CMB data and $3.2\sigma$ with supernovae also included. Its new high-redshift measurement moves closer to $\Lambda$CDM. This is evidence to retain alternatives, not a measurement of the equation of state trillions of years from now. In particular, extrapolating the convenient $w_0,w_a$ fitting function to arbitrarily large future scale factor is not a physical prediction. [DESI DR2 IV](https://arxiv.org/abs/2607.27410).

For a flat FLRW metric, choose $a(t_0)=1$ and define remaining comoving light-travel distance

$$\chi_\infty(t)=c\int_t^\infty \frac{dt'}{a(t')}.$$

At the present epoch, our integration gives:

| Quantity | Present-distance equivalent |
|---|---:|
| Hubble radius, $c/H_0$ | 14.51 Gly |
| Future event-horizon radius, $\chi_\infty(t_0)$ | 16.68 Gly |
| Particle-horizon radius | 46.13 Gly |
| Asymptotic de Sitter horizon, $c/H_\Lambda$ | 17.53 Gly |

Here Gly means a billion light-years. The present particle horizon concerns photons arriving from the past; it is not a resource-acquisition radius. Nor is instantaneous recession faster than $c$ the general criterion for causal loss: the entire future integral matters. [Davis & Lineweaver, *Expanding Confusion*](https://arxiv.org/abs/astro-ph/0310808).

## 2. Three resource questions with different answers

**One-way descendants.** A front with fixed peculiar speed $\beta c$ relative to the cosmological matter frame, starting now, reaches comoving radius arbitrarily close to $\beta\chi_\infty$. This is the relevant geometry if a remote descendant's computation has value even when its result can never return. For nonzero rest mass, $\beta=1$ is a limiting envelope, not an attainable travel speed.

**Answers sent back.** To commission a computation at comoving distance $\chi$ and receive its result at the original comoving location, the outgoing trip consumes $\chi/(\beta c)$ of conformal time, and the photon reply consumes $\chi/c$. Therefore

$$\chi<\frac{\beta}{1+\beta}\chi_\infty.$$

At $\beta\to1$, the radius is 8.34 Gly, with one-eighth of the initially reachable volume. This is a two-leg communication constraint, not an assumption about redshift energy losses. Extra relays cannot beat it: their causal path lengths still consume conformal time. A finite computation duration or finite reply bandwidth further reduces the usable region.

**Fuel returned.** Returned mass or energy shares the same causal restriction, plus propulsion, conversion, and transport losses. Returning massive cargo at fixed peculiar speed $u c$ replaces $\beta/(1+\beta)$ by $\beta u/(\beta+u)$. Keeping $u$ fixed requires propulsion against cosmological momentum redshift. Thus it is a kinematic bound, not a cheap transport plan.

**Can a migrating receiver improve the causal mass bound?** In the light-speed envelope, let the final receiver have limiting comoving displacement $d$ from the origin, and write $L=\chi_\infty$. A comoving resource at $\mathbf r$ can receive an instruction from us and contribute to that receiver only if $|\mathbf r|+|\mathbf r-\mathbf d|<L$. This is a prolate ellipsoid with semiaxes $L/2$ and $\sqrt{L^2-d^2}/2$. Its volume is $\pi L(L^2-d^2)/6$, maximized at $d=0$. Thus migration does not increase the homogeneous matter available for an instructed task with one final answer. It can certainly improve access in an inhomogeneous nearby universe, or change transport energetics. This elementary geometric deduction is not an optimality theorem for fuel extraction in dynamical gravity.

These are derivations within FLRW geometry. The broader operational principle—an experiment beginning at $p$ and returning a result at $q$ lives in $J^+(p)\cap J^-(q)$—is standard. Bousso's treatment is especially useful for connecting that causal diamond to entropy bounds; the accompanying finite-dimensional-Hilbert-space interpretation is a quantum-gravity proposal, not an established device architecture. [Bousso, *Positive Vacuum Energy and the N-bound*](https://arxiv.org/abs/hep-th/0010252).

“A decent fraction of the universe” needs a denominator. At the light-speed limit, the one-way region contains about 4.73% of the matter within today's particle horizon, assuming a homogeneous distribution; the returned-task region contains 0.591%. The ideal photon-return protocol below delivers the equivalent of about 0.213% of that presently observable matter's rest energy. Relative to *initially one-way-reachable* matter energy, its yield is 4.50%. None of these is a fraction of the entire possibly infinite spatial universe.

Olson's expansion-front work is a useful model of distributed domains. It treats expansion, appearance, and resource-consumption strategies geometrically, rather than assuming one central computer. The accessible region is only a kinematic opportunity: replication and resource conversion must be supplied separately. [Olson, *Homogeneous cosmology with aggressively expanding civilizations*](https://arxiv.org/abs/1411.4359); [Olson, *Expanding cosmological civilizations on the back of an envelope*](https://arxiv.org/abs/1805.06329).

## 3. An explicit optimistic photon-return calculation

Assumptions: a negligibly costly front at peculiar speed $\beta c$; homogeneous comoving matter; instantaneous conversion of a fraction $\epsilon$ of rest energy into directed photons; perfect capture at the origin; no absorption, finite aperture, backreaction, storage losses, or reply task. This is a transparent benchmark, not an established upper bound over every possible harvesting scheme.

Label each shell by its **present** proper radius $\chi$; its invariant rest mass is

$$dM=4\pi\rho_{b,0}\chi^2d\chi.$$

If $\eta(t)=\int_{t_0}^t dt'/a(t')$, conversion occurs at $\eta_e=\chi/(\beta c)$ and reception at $\eta_a=\chi(1+1/\beta)/c$. Each photon's energy is redshifted by $a_e/a_a$, so

$$E_{\rm recv}=\epsilon c^2\int_0^{\beta\chi_\infty/(1+\beta)}4\pi\rho_{b,0}\chi^2\frac{a(\eta_e)}{a(\eta_a)}d\chi.$$

The shell mass is conserved; one must not separately multiply it by the lower density at encounter. If one uses that physical density instead, the physical volume contains the compensating $a_e^3$ factor.

The code evaluates the integral in the fiducial $\Lambda$CDM model, with $\epsilon=1$:

| Outbound speed | One-way radius | Return radius | Received baryonic energy | Erasures at $T_{dS}$ |
|---|---:|---:|---:|---:|
| $0.01c$ | 0.167 Gly | 0.165 Gly | $5.51\times10^{62}$ J | $2.62\times10^{115}$ |
| $0.1c$ | 1.668 Gly | 1.516 Gly | $3.13\times10^{65}$ J | $1.49\times10^{118}$ |
| $0.5c$ | 8.340 Gly | 5.560 Gly | $1.00\times10^{67}$ J | $4.77\times10^{119}$ |
| $c$ limit | 16.679 Gly | 8.340 Gly | $2.80\times10^{67}$ J | $1.33\times10^{120}$ |

Multiply the last two columns by $\epsilon$. Counting all matter rather than baryons multiplies them by $\Omega_m/\Omega_b=6.39$, but dark matter capture and conversion are unspecified. The baryonic figures include diffuse gas, not just stars. The existing cosmic microwave background is not counted as freely convertible work.

The erasure column divides the energy by $k_BT_{dS}\ln2$, where $T_{dS}=\hbar H_\Lambda/(2\pi k_B)=2.20\times10^{-30}$ K. The horizon's thermality is the semiclassical Gibbons–Hawking result. Reaching this asymptotic bath, performing finite-time erasure near its Landauer cost, and retaining the computer are distinct assumptions. [Gibbons & Hawking, *Cosmological event horizons, thermodynamics, and particle creation*](https://doi.org/10.1103/PhysRevD.15.2738).

**Comparison with Krauss–Starkman.** Their paper presents an outward-converter/inward-photon scheme, quotes $1/64$ of initial horizon matter energy in pure de Sitter, and obtains $1.35\times10^{120}$ processed bits using then-current parameters. Their headline is not a count of FLOPs. [Krauss & Starkman, *Universal Limits on Computation*](https://arxiv.org/abs/astro-ph/0404510). Our near-equality to that headline is partly accidental: we use baryons, updated parameters, a numerical FLRW calculation, and a different shell weighting. See `KS_CONSTANT_AUDIT.md` for the specific discrepancy rather than silently replacing their coefficient.

## 4. Avoiding both escape and collapse

For a spherically symmetric gravitating reservoir in the weak-field regime, the cosmological repulsion balances gravity at

$$r_{\rm ta}=\left(\frac{GM}{H_\Lambda^2}\right)^{1/3}=\left(\frac{3GM}{\Lambda c^2}\right)^{1/3}.$$

This is a maximum turnaround radius, not a stable shell. At the radius itself, force balance is unstable. Matter comfortably inside it can be bound; merely starting inside it with arbitrarily large outward velocity is not enough. The derivation and the spherical-symmetry assumption are explicit in [Pavlidou & Tomaras, *Where the world stands still*](https://arxiv.org/abs/1310.1920).

At the other extreme a Schwarzschild radius is $r_s=2GM/c^2$. A useful necessary geometric window is

$$r_s\ll R\ll r_{\rm ta}.$$

The inequalities are not a proof of a stable engineered object, but they show why gathering matter need not imply making a black hole. In the Newtonian point-mass potential plus $\Lambda$, stable circular test-particle orbits require $R<r_{\rm ta}/4^{1/3}$; this follows by differentiating the effective potential. A bound reservoir can be an orbiting distribution, not a rigid shell under compression.

| Illustrative mass | $r_s$ | $r_{\rm ta}$ | Ratio $r_{\rm ta}/r_s$ |
|---|---:|---:|---:|
| One solar mass | 2.95 km | 111 pc | $1.16\times10^{15}$ |
| $5.43\times10^{10}$ solar masses | 0.0170 ly | 0.422 Mpc | $8.12\times10^7$ |
| $3\times10^{12}$ solar masses | 0.937 ly | 1.61 Mpc | $5.60\times10^6$ |
| Collected photon-energy equivalent, baryons, $c$ limit | 48.9 Mly | 601 Mpc | 40.0 |

The first three masses are examples; the Local Group row includes predominantly dark matter and does not imply that all of it is fuel. The last row has $M=3.12\times10^{50}$ kg. A spherical reservoir of that mass at $R=r_{\rm ta}/2=0.98$ Gly has $r_s/R\simeq0.050$ and $H_\Lambda^2R^2/c^2\simeq0.0031$: its exterior is well outside either horizon. Achieving and retaining the configuration is still an engineering problem.

The exact spherically symmetric exterior factor is

$$f(r)=1-\frac{2GM}{c^2r}-\frac{H_\Lambda^2r^2}{c^2}.$$

A static region exists only while its maximum is positive. Solving $f=f'=0$ gives the Nariai mass

$$M_N=\frac{c^3}{3\sqrt3\,GH_\Lambda}=4.30\times10^{52}\ {\rm kg},\qquad r_N=\frac{c}{\sqrt3H_\Lambda}=10.12\ {\rm Gly}.$$

This is a property of the spherical Schwarzschild–de Sitter family, not a theorem bounding mass on an arbitrary cosmological slice. In particular, applying the flat-space Schwarzschild formula to a homogeneous expanding ball and declaring the universe a black hole is invalid. The derivation here uses the exterior metric, not that shortcut.

The ideal returned baryonic energy is just $0.0073M_Nc^2$. Its geometric storage window exists even though it is much too massive to squeeze into a small fast processor. The correct architecture separates **active working memory and gates** from **fuel reserves**. Fuel can be metered toward a smaller computer over time; waste energy is then emitted rather than left to build up centrally. No speed-of-light law requires all fuel to participate in each logic step.

This addresses the user's sequential-computation question positively at the geometric level. It does not establish that $10^{120}$ reliable sequential steps can be completed. Small working memory, stable storage, low-loss conversion, low-temperature heat transfer, and cumulative errors may impose much tighter limits. If memory itself must encompass the whole reservoir, memory-access latency replaces the fuel-delivery nonproblem.

## 5. Engineering proposals and their status

Without interventions, positive-$\Lambda$ structure simulations leave finite bound islands, while unbound objects eventually become inaccessible. The qualitative distinction survives changed parameters; individual merger predictions are contingent and should not be repeated as inevitabilities. [Nagamine & Loeb, *Future Evolution of Nearby Large-Scale Structure*](https://arxiv.org/abs/astro-ph/0204249).

Hooper studies collecting stars with powered stellar engines. In the proposed scheme stars around $0.2$–$1$ solar masses are attractive, and a civilization expanding at $0.1c$ can collect out to roughly 50 Mpc (20 Mpc at $0.01c$). Those radii are much smaller than the causal ceiling because stellar luminosity, acceleration, and lifetime matter. The assumed transfer of stellar power into useful propulsion goes beyond a simple photon thruster. These are useful worked engineering scenarios, not demonstrated capabilities. [Hooper, *Life Versus Dark Energy*](https://arxiv.org/abs/1806.05203).

Armstrong and Sandberg offer a complementary argument that launching extremely light, self-replicating intergalactic probes can be energetically modest for a stellar civilization. It does not show that moving the encountered stars back to a common center is equally cheap. [*Eternity in six hours*](https://doi.org/10.1016/j.actaastro.2013.04.002).

Long-term astrophysical storage is an extra problem. Ordinary stellar systems eject members and transfer some mass to black holes; stellar fuel is used without regard for a future owner's preferences; baryon stability is not settled. Black holes provide long-lived reservoirs but change accessible entropy and useful power. Treat natural-object lifetime estimates as conditional scenarios, especially where proton decay or dark-matter annihilation is assumed. [Adams & Laughlin, *A Dying Universe*](https://arxiv.org/abs/astro-ph/9701131).

Nor can one simply count dark energy as another 68% of fuel. Davies analyzes lowering-and-raising apparatus near a de Sitter horizon; accounting for the required investment and the second law obstructs a perpetual source of useful work. Thermal energy is not the same resource as free energy. [Davies, *Mining the Universe*](https://doi.org/10.1103/PhysRevD.30.737).

## 6. Decision-theoretic consequences: research, expansion, and software updates

These are our deductions from the access geometry, not empirical forecasts of future behavior.

**The value of delay.** For a homogeneous one-way domain, $M(t)\propto[\beta(t)\chi_\infty(t)]^3$. Hence

$$\frac{d\ln M}{dt}=3\frac{d\ln\beta}{dt}-\frac{3c}{a(t)\chi_\infty(t)}.$$

With fixed speed, the present geometric loss is about $0.180$ per Gyr, or $1.8\times10^{-10}$ per year. Delaying launch by one million years loses approximately 0.018% of reachable matter; by a billion years, about 16%; by ten billion years, about 83%. A large immediate R&D return can easily dominate the geometric cost of a modest delay. Conversely, waiting the roughly trillion-year cooling time before *beginning acquisition* would sacrifice nearly all initially unbound resources.

**Frontiers can receive upgrades.** Set conformal time to zero now and denote its future limit by $\eta_\infty$. An existing $\beta c$ front is at $\chi_f=\beta c\eta$. A software signal launched from home at $\eta_d$ is at $\chi_s=c(\eta-\eta_d)$. They meet at $\eta=\eta_d/(1-\beta)$, before the future limit only if

$$\eta_d<(1-\beta)\eta_\infty.$$

Thus a slower front can carry early machinery while later intelligence improvements catch it. Under the baseline cosmology the last home update that can catch the terminal $0.1c$ frontier can be sent about 40 Gyr from now, versus zero delay in the unattainable $c$ limit. Updates after that still reach interior nodes. This comparison assumes a persistent communication channel and only concerns causality, not finite message energy or bandwidth.

**There need not be a universal foom-coom time.** The earlier single-budget model assumes research benefits every future unit of consumption. In a fragmented cosmic network, a discovery's value depends on which descendants can still receive it. There may be a research phase shared by everyone, ongoing local research, acquisition that starts before research finishes, and different consumption schedules in different bound islands. A more faithful optimization has location- and time-dependent research spillovers plus resource loss and reliability hazards.

**Utility changes the architecture.** If value is additive over independent lives, leaving resources in separate bound islands can avoid costly centralization. If value requires one long history with one persistent state, a collected reserve and compact processor may be preferable. If value lies in a globally integrated simulation, communication cuts and geometry are essential constraints. These objectives can produce different optima with the same total energy budget.

## 7. What remains unresolved

- Is the future asymptotically de Sitter at all? Rolling dark energy, vacuum transitions, or recollapse change horizons, bath temperatures, and available proper time.
- What fraction of baryonic mass can actually be converted into *stored work*? Directed rest-energy conversion is a deliberately optimistic assumption; stellar fusion is neither unit efficiency nor freely timed.
- How close can gravitational engineering approach the test-background photon-return calculation? A realistic calculation must include backreaction, transport stress-energy, aperture, conversion entropy, and reserve stability.
- What is the best energy-extraction protocol if a result may be received by a migrating observer rather than at the original location? The ellipsoid argument bounds homogeneous causal mass for the light-speed envelope, but optimality of returned usable energy over moving endpoints is not proven here.
- Can matter, memory, and control survive the extraordinarily long durations required for deep, cold, low-dissipation computation? Geometry grants time, not reliability.
- What is the Pareto frontier of returned answers, independent experiences, preserved memory, and research spillovers? A scalar number of operations hides these distinctions.

## Literature map and provenance

Primary sources directly reviewed: Planck 2018 VI; DESI 2026 DR2 IV; Davis–Lineweaver 2004; Bousso 2000; Krauss–Starkman 2004; Gibbons–Hawking 1977; Pavlidou–Tomaras 2014; Nagamine–Loeb 2003; Hooper 2018; Armstrong–Sandberg 2013; Olson 2015/2018; Adams–Laughlin 1997; Davies 1984. Public URLs are attached to the relevant claims above.

`calculate_access.py` contains the independent numerical integration and analytic cross-checks. `access_results.json` is the machine-readable output. `KS_CONSTANT_AUDIT.md` records a candidate correction to a published coefficient; it is separated so it can be independently checked without affecting the general conclusions.
