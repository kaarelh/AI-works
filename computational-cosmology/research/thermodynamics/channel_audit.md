# Audit of the Pendry entropy-export model

8 October 2026. Requested synthesis audit; derivations below independently checked algebraically. The main memo is complete. This addition provides a cleaner channel calculation than the deliberately inconsistent horizon-sized blackbody extrapolation.

## Vacuum channels: the proposed formula is correct

For one ideal lossless one-way bosonic channel, a thermal occupation maximizes entropy flux at fixed mean energy flux. With SI entropy units, its parametric fluxes are

\[
P(T)=\frac{\pi k_B^2T^2}{12\hbar},\qquad
\dot S(T)=\frac{\pi k_B^2T}{6\hbar}.
\]

Eliminating temperature gives

\[
\dot I\le\sqrt{\frac{\pi P}{3\hbar\ln^22}}.
\]

A channel here includes one propagation direction and one transverse/spin/polarization mode, with a continuum of temporal/frequency modes. It is **not** one wire regardless of its transverse mode count, one arbitrary area pixel, or one physical processor. For C independent equivalent channels and total power P, optimal power sharing gives

\[
\dot I\le\sqrt{\frac{\pi C P}{3\hbar\ln^22}}.
\]

By Cauchy–Schwarz, over an interval,

\[
B^2\le \frac{\pi E}{3\hbar\ln^22}\int C(t)\,dt.
\]

For constant C this becomes the proposed \(B\le\sqrt{\pi C E\tau/(3\hbar\ln^22)}\). Equality requires the ideal encoding/channel assumptions and optimized temporal/power allocation.

Primary references: [Pendry, Quantum limits to the flow of information and entropy, 1983](https://doi.org/10.1088/0305-4470/16/10/012); [Caves and Drummond, Quantum limits on bosonic communication rates, 1994](https://doi.org/10.1103/RevModPhys.66.481). The latter explicitly defines one channel as one transverse mode and polarization and derives a bound independent of encoding/detection scheme. A convenient short derivation and the comparison with black-hole emission are in [Bekenstein and Mayo, Black holes are one-dimensional, 2001](https://arxiv.org/abs/gr-qc/0105055).

## Combining with Landauer: a necessary timescale, not saturation

If E denotes the work/energy budget ultimately spent exporting erased entropy and T is a fixed equilibrium sink, Landauer requires \(B\le E/(k_BT\ln2)\). Combining this erasure-budget bound with the vacuum-channel bound supplies the necessary condition

\[
\tau\ge {3\hbar E\over\pi C(k_BT)^2}
\]

for an erasure count *as large as* E/(kBT ln2) not already to violate the channel inequality. Substituting TdS and the hypothetical B gives

\[
\tau\ge {6\ln2\over CH}B.
\]

At H=1.8078×10^-18/s, B=10^120 and C=1, this is 7.29×10^130 years. **Do not call it a sufficient achievable saturation time.** A vacuum channel and a nonzero-temperature bath are different boundary conditions; exact reversible Landauer saturation normally requires vanishing power/gradient.

There is also a bookkeeping caveat: when P is *gross outgoing* power but E is *net work consumed*, one cannot simply identify their integrals in a thermal environment. Thermal background contributes energy and entropy in both directions. Either use vacuum as an optimistic auxiliary relaxation with energy counted consistently, or explicitly model the background.

## A stronger explicitly thermal transport model (own derivation)

Consider C perfect bosonic transport modes. Incoming modes have an equilibrium thermal occupation at fixed Tb, outgoing modes can be prepared at To≥Tb. Define

\[
a={\pi Ck_B^2\over12\hbar},\quad
P_{\rm net}=a(T_o^2-T_b^2),\quad
\dot S_{\rm net}=2a(T_o-T_b).
\]

These are **net** outgoing minus incoming fluxes. For a fixed outgoing mean energy, thermal occupation maximizes outgoing entropy. Eliminating To yields

\[
P_{\rm net}\ge T_b\dot S_{\rm net}
+{3\hbar\over\pi Ck_B^2}\dot S_{\rm net}^2.
\]

Thus exporting \(k_B\ln2\,B\) of extra entropy in time τ at fixed C obeys

\[
\boxed{E\ge k_BT_b\ln2\,B+
\frac{3\hbar\ln^22}{\pi C\tau}B^2.}
\]

The first term is the slow-limit Landauer cost; the second is a finite-throughput penalty. This is a transparent architecture-dependent model, not a universal curved-spacetime theorem. The calculation uses ideal broadband lossless modes, a thermal incoming stream, no additional chemical/spin work reservoirs, and consistent local time/energy. A channel construction that avoids incoming thermal noise needs its own energy and purity accounting.

If \(\eta=Bk_BT_b\ln2/E\) is the fraction of the static Landauer maximum attained, then

\[
\tau\ge\frac{3\hbar\ln2\,B}{\pi Ck_BT_b}\frac{\eta}{1-\eta}.
\]

At TdS,

\[
\boxed{\tau\ge {6\ln2\,B\over CH}\frac{\eta}{1-\eta}.}
\]

For B=10^120, C=1: η=1/2 gives 7.29×10^130 yr, η=0.9 gives 6.56×10^131 yr, η=0.99 gives 7.22×10^132 yr. These compare fixed *B* at different total E; be explicit about that convention. Exact η=1 requires τ→∞ in this ideal thermal channel model.

For variable C(t) at fixed Tb, minimizing integrated quadratic dissipation at fixed B gives the same formula with \(C\tau\) replaced by \(\int C(t)dt\). If Tb changes, the linear term is \(k_B\ln2\int T_b(t)dB(t)\), and the entropy schedule becomes another optimization variable.

## Caveats which should appear near any headline number

- This bounds **entropy exported through the specified channels**. If the machine places noise into internal reservoirs, B_gate and B_export differ. Storage can postpone the bottleneck.
- There is no established universal C=1 bound for an engineered cosmological civilization. Many independent modes, species, transport media, geometric apertures, and carrier streams can matter. C=1 is an example.
- Applying local flat-space transport equations to a horizon requires redshift, angular barriers/greybody factors, mode availability, and observer-time conventions. Taking C as a freely scalable constant all the way to wavelengths larger than the horizon is unjustified.
- More work, hotter carriers, larger channel count, or slower runtime can trade against one another. For useful gates one also needs the entropy generated per gate.
- A large B, by itself, is not memory capacity, sequential depth, or total gate count. The report should phrase this as a *joint budget-and-export-time frontier for one ideal architecture*.
- Quantum entanglement-assisted classical message capacity is not automatically identical to thermodynamic entropy export. The present calculation counts exported entropy and charges all additional purity/entanglement resources separately.

## Verdict

The parent formulation has the right Pendry coefficient, C-scaling, integrated bound, and de Sitter timescale. The key correction is interpretive: the crossed vacuum/Landauer inequalities establish only a necessary compatibility timescale. For a clean report I recommend either (a) use them as loose necessary bounds with consistent energy accounting, or preferably (b) show the explicit thermal model above, whose sum of an energy cost and a finite-rate penalty makes the distinction impossible to miss.
