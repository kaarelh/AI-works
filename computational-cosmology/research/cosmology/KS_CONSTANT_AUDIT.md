# Independent audit of the Krauss–Starkman photon-return coefficient

Status: an independent derivation identifies an apparent volume/density mismatch in the published coefficient. This note presents the explicit protocol and published result separately; it is not a confirmed published correction. No published correction or discussion of this coefficient was found in targeted searches on 8 October 2026.

Source: [Krauss and Starkman, astro-ph/0404510v2](https://arxiv.org/pdf/astro-ph/0404510), page 2, Eqs. (4)–(6). The original PDF agrees with the arXiv HTML conversion. They explicitly define the integration radius as $R=a_0r$, where $r$ is comoving radius. Their $\rho_m$ is called the matter energy density, with $\Omega_m=\rho_m/\rho_c$.

## Unambiguous protocol

Use a fixed de Sitter background $a(t)=e^{Ht}$; non-gravitating comoving dust is a test resource. Set $a_0=1$. Send a zero-cost signal/converter front at $c$, convert the rest mass of every initial shell into inward photons immediately upon first arrival, and collect the photons at the origin. Backreaction and actual conversion feasibility are outside this calculation.

With $x=HR/c$, the outgoing arrival has $a_e=(1-x)^{-1}$ and the returning photon arrival has $a_a=(1-2x)^{-1}$. Thus

$$\frac{E_a}{E_e}=\frac{1-2x}{1-x},\quad 0<x<1/2.$$

The initial shell rest energy is $dE_0=4\pi\rho_{m,0}R^2dR$, where $\rho_{m,0}$ is an **energy** density. Its rest energy remains the same before conversion: at arrival the physical shell volume is $a_e^3\,4\pi R^2dR$, and physical density is $\rho_{m,0}a_e^{-3}$.

Therefore, relative to initial matter energy inside $c/H$,

$$f_{\rm direct}=\int_0^{1/2}3x^2\frac{1-2x}{1-x}\,dx=\frac{17}{8}-3\ln2=0.045558458320164\ldots.$$

The primitive is $2x^3+\tfrac32x^2+3x+3\ln(1-x)$. The integral was also checked numerically with SciPy.

## How the published coefficient is reproduced

The paper's stated $1/64$ is exactly obtained from

$$\int_0^{1/2}3x^2(1-x)^3\frac{1-2x}{1-x}\,dx=\frac1{64}.$$

The extra $(1-x)^3=a_e^{-3}$ is physical density dilution. It should cancel physical volume expansion when shells are labelled by present/comoving radius. Differentiating the paper's closed form $R_*^3(1-HR_*/c)^3$ reproduces precisely this extra factor. The direct fraction is $2.91574133$ times larger.

The causal one-eighth-volume limit is unaffected. Only the energy-weighting coefficient changes. At slow outbound speed the detailed coefficient changes differently; `calculate_access.py` evaluates the explicit protocol directly and should be used rather than multiplying every published number by 2.9157.

## Reservations and comparison policy

- The supplied derivation is about a test-dust protocol in a prescribed metric. Pure de Sitter plus dynamically significant homogeneous matter is not itself an exact cosmology.
- Photon energies are measured in the local comoving frames at emission and absorption. There is no claim of a globally conserved FLRW photon energy.
- The calculation assigns no cost to launching or constructing converters, conversion, collimation, or energy storage. It is an optimistic transport benchmark.
- The broader reported $10^{120}$ magnitude survives. It must still be called an irreversible-information or entropy budget under stated assumptions, not a universal count of arbitrary logical gates.
- This comparison concerns the physical interpretation and calculation of a resource budget. It does not automatically revise conclusions of a separate model that stipulates its compute budget as an assumption.
