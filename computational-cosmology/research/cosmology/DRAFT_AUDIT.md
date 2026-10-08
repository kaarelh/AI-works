# Cosmology review of the main draft

Reviewed `computational_cosmology/report.md` on 8 October 2026. Surgical edits were confined to sections 3, 4, and 8 as requested. No appendix was edited.

## Corrections made

1. Section 3's migration result now explicitly assumes initially comoving resources; an inflowing mass distribution or pre-existing independently active infrastructure is a different problem.
2. Section 4 now describes a geometric window rather than implying an attained reservoir, and identifies the turnaround criterion as a condition for **passive gravitational binding in the spherical model**. Active support is not excluded by a turnaround bound alone.
3. Section 8 states the software deadline as a strict inequality. For a $0.1c$ frontier, the computed threshold is 40.077 Gyr after the reference present. A message emitted exactly at that threshold does not catch the frontier at a finite event; the interception occurs only in the conformal boundary limit. Earlier messages can catch it in the ideal channel model.

## Numerical checks

All numerical values checked against `access_results.json`:

- Present event horizon 16.67935 Gly; particle horizon 46.13327 Gly.
- Light-speed returned-task envelope 8.339675 Gly; homogeneous volume is one-eighth of one-way volume.
- Received baryonic photon energy $2.80068\times10^{67}$ J; mass equivalent $3.11618\times10^{50}$ kg.
- Corresponding Schwarzschild scale 48.9206 Mly and maximum turnaround scale 1.95879 Gly (600.586 Mpc).
- At radius $r_{\rm ta}/2$, compactness $r_s/R=0.04995$ and cosmological term $H_\Lambda^2R^2/c^2\simeq0.003122$. The exterior is safely in its static region; this is not a construction proof.
- Asymptotic temperature $2.19755\times10^{-30}$ K; horizon entropy $4.77194\times10^{122}$ bits.
- Photon protocol erasure equivalents $1.33173\times10^{120}$ at light-speed envelope; $1.48910\times10^{118}$ at $0.1c$.
- Launch delay losses: 1 Myr 0.01798%; 1 Gyr 16.3977%; 10 Gyr 82.6539%.

## Section 6 point for root to adjust

The numerical 29-day and 8-billion-year radius-crossing scales from the spherical area envelope are correct. However, the equation $\tau_{\rm global}\gtrsim t_P\sqrt{B\ln2/\pi}$ needs an explicit **weak-field/local-flat crossing-time interpretation**, not a hardware-independent proper-clock bound at arbitrary gravitational redshift. The 8-billion-year case is already cosmological, and saturation of the area bound usually invokes strongly gravitating/horizon states rather than usable RAM. Suggested precise framing:

> Combining the area envelope with the flat-space estimate $\tau\gtrsim R/c$ gives an illustrative radius-crossing scale [...]. It is not a general proper-time theorem in strongly curved spacetime; near cosmological or black-hole horizons the geometry and chosen clock must be modeled explicitly.

The existing caveat “exact geometry matters” is directionally right, but calling the pair universally “two necessary constraints” before it is stronger than justified. The first two numbers can remain as intuition, clearly separated from realizability.

## Migration derivation for Appendix A

Let $p$ be initiation at conformal time $\eta_p$, position 0, and $q$ reception at conformal time $\eta_q$, comoving position $\mathbf d$. Set $L_q=c(\eta_q-\eta_p)$ and $d=|\mathbf d|<L_q$. A comoving resource worldline at $\mathbf r$ can be reached by an instruction from $p$ and influence $q$ only if

$$|\mathbf r|+|\mathbf r-\mathbf d|\leq L_q.$$

Ignoring processing duration gives a prolate ellipsoid with semimajor axis $L_q/2$ and equal minor axes $\sqrt{L_q^2-d^2}/2$. Its volume is $\pi L_q(L_q^2-d^2)/6$, maximized at $d=0$. Finite computation tightens the inequality.

For an indefinitely continuing timelike receiver in flat FLRW with finite $\eta_\infty$, its spatial path has total comoving variation at most $c(\eta_\infty-\eta_p)$, so its position converges to a limiting $\mathbf d_\infty$. Every commissioned resource that feeds some finite point of that receiver's history lies within the limiting ellipsoid obtained with $L=c(\eta_\infty-\eta_p)$ and $\mathbf d=\mathbf d_\infty$. Thus a designated finite final answer is not essential to the necessary geometric envelope. The limiting boundary is not a physical reception event, and inclusion in the envelope is not a sufficient condition for timely collection. This proves a homogeneous comoving-mass statement, not maximal extractable work, engineered backreaction, or an upper bound over independent descendants.

## Overall assessment

The main cosmology conclusions are well-supported with the adjustments above. The strongest useful claim is the separation of finite acquisition/communication opportunity from potentially unlimited proper time in a bound laboratory. The report correctly keeps fuel reserves separate from actively interacting working state. All resource yields remain explicitly protocol-dependent, and the eternal positive-$\Lambda$ assumption is visible rather than smuggled into an unconditional forecast.
