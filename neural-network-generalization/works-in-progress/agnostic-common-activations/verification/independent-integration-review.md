# Independent review of the localized common-activation paper

Reviewed the seven included source modules on 18 November 2026. No substantive gap was found. This is a conventional mathematical audit, not a Lean formalization. The earlier finite-grid/Hoeffding baseline remains separately reviewed in common-activation-baseline.

The dictionary and teacher construction retain their independently audited content. The explicit good set includes the amplitude bound as well as L2 approximation. The fixed-radius teacher comparison gives one resource A_(m,B,n) valid for every lambda>=1/n; its output squared amplitude is bounded by a constant times E^L.

The localized statistical module was independently checked and separately reviewed by oracle_calibration. Finite-class Bernstein at absolute accuracy a~lambda K/sqrt(u) gives rho=(q+2)/2 and v=p+L=L rho. The sample-dependent multiscale complexity has pointwise uniform prior tails, a measurable countable definition, and controlled exponentially tilted raw-risk moments. Statistical uniformity is applied only to deterministic finite dictionaries. The objective tail and entropy absorption give the observable certificate; teacher Bernstein absorption preserves coefficient one.

The integrated main statements match the proof: every globally Lipschitz activation, arbitrary bounded IID labels, one fixed independent Gaussian architecture, all finite widths above the comparator width, all sigma²<=1/N, ordinary raw posterior mean and posterior-averaged raw risk. At H>=2 the powers are v=2H(H+1), rho=2H; generic H1 has v=5,rho=5/2. Constants retain polynomial input-dimension dependence at fixed depth. No claim of polynomial joint depth dependence is made.

The final deterministic-calibration appendix is valid. Its preset lambda=(theta U0^(v-rho))^(1/v) satisfies the inequality actually required by the localized proof; equality with observed free energy is unnecessary. It therefore retains the improved fixed-positive-risk polynomial exponent, while the data-dependent root gives the stronger risk-adaptive and zero-risk terms. Fallback and confidence bookkeeping agree with the main proof.
