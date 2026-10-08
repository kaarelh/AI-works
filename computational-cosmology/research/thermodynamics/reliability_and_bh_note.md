# Reliability and black-hole storage: quantitative checks

8 October 2026. Focused follow-up. The numbers below use H=1.807817712×10^-18/s and the same physical constants as the main calculations.

## Long duration is not by itself an impossibility argument

For n passive memory cells with stationary thermal escape rate ν exp(-Eb/kBT), a union bound gives

\[
P(\text{any escape})\lesssim n\nu t e^{-E_b/k_BT}.
\]

Thus sufficient suppression of this particular failure mode to δ requires Eb/kBT≥ln(nνt/δ). This is the activated-barrier approximation, not a universal failure law. [Kramers 1940](https://doi.org/10.1016/S0031-8914(40)90098-2); a primary scan is [available at MIT](https://www.mit.edu/~kardar/research/seminars/translocation/Kramers1940.pdf).

For t=7.28984×10^130 years, ν=10^12/s and δ=.01, the dimensionless barrier is 350.826+ln n:

| Cells n | Required Eb/kBT | Equivalent Eb at 300 K |
|---:|---:|---:|
| 1 | 350.83 | 9.07 eV |
| 10^30 | 419.90 | 10.86 eV |
| 10^60 | 488.98 | 12.64 eV |
| 10^90 | 558.06 | 14.43 eV |

The illustrative 300-K column is just an energy conversion, **not a claim that a 10-eV physical memory actually survives for 10^130 years**. Tunneling, radioactive or particle decay, environmental shocks, barrier stability, correlations, and the machinery that switches or repairs the register have not been modeled. At ultralow temperature, classical thermal activation will often cease to be the controlling failure mode. Nevertheless, this calculation is a concrete reason not to dismiss extreme runtimes using the phrase “maintenance is impossible”: this well-understood failure mode depends logarithmically on duration.

Active fault tolerance likewise can suppress logical errors exponentially in code distance under appropriate local-noise assumptions, so target reliability over D operations typically costs a distance growing like log(D/δ), not D. Physical faults and syndrome entropy still accumulate and must be handled. The assumption that the noise model and controller remain valid over the whole run is substantial. [Fowler et al. 2012](https://arxiv.org/abs/1208.0928).

## A black hole is long-lived, but not a timeless battery

For M=3.12×10^50 kg, the ordinary neutral, nonrotating, freely evaporating flat-space blackbody formulas give

\[
\tau_{\rm evap}=\frac{5120\pi G^2M^3}{\hbar c^4}=8.0953\times10^{127}\ \mathrm{yr},
\]

\[
T_H=\frac{\hbar c^3}{8\pi GMk_B}=3.9324\times10^{-28}\ \mathrm K,
\qquad r_s=4.6339\times10^{23}\ \mathrm m.
\]

Its initial temperature is 178.93 TdS, its Schwarzschild radius is .002794 R_dS, and its horizon entropy is 3.7257×10^117 bits. Its initial textbook Hawking power is 3.6588×10^-69 W. The earlier one-channel, 50%-Landauer-efficiency export example lasts 900.5 times this blackbody lifetime.

The Hawking effect is the physical basis; the simple lifetime coefficient treats emission approximately as blackbody radiation. Actual species and greybody transmission alter it. [Hawking 1975](https://doi.org/10.1007/BF02345020), [Page 1976](https://doi.org/10.1103/PhysRevD.13.198). For this ultracold hole, the massive-neutrino contribution in historical massless-particle estimates is not automatically applicable.

**Interpretation:** a freely leaking hole of this mass cannot simply be assumed to hold the fuel unchanged throughout that particular much longer export schedule. This is a useful architecture consistency check. It is not an impossibility proof: capture and store or recycle the radiation, inhibit leakage, introduce additional channels, or use a hotter/faster schedule, and the comparison changes. Reflecting enclosures and recycling themselves require a physical model.

Cosmological backreaction at the black-hole horizon is initially modest because r_s≪R_dS. The mass is .00726 of the Schwarzschild–de Sitter Nariai scale c³/(3√3 GH). Incoming CMB radiation postpones free evaporation until the background cools sufficiently; a pure-de-Sitter cooling extrapolation puts the crossing of the *initial* Hawking temperature about 1.12×10^12 years from now, negligible compared with 10^128 years. These observations justify the flat formula as an order-of-magnitude illustration, not as a precise cosmological lifetime. Accretion, rotation, charge, external trapping, unknown light species, and vacuum stability remain separate choices.
